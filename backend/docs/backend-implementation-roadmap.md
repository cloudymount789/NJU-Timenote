# NJU Timenote 后端实施路线图

本文档从后端开发者的视角，完整梳理 NJU Timenote 当前状态、后端需要完成的工作，以及前端代码的现状与待修改点。

最后更新：2026-06-11

---

## 1. 项目架构总览

```
NJU-Timenote/
├── backend/                         # 后端（你的工作目录）
│   ├── app/main.py                  # FastAPI 入口
│   ├── app/core/config.py           # 配置（环境、Host、文档开关）
│   ├── app/api/router.py            # 路由注册
│   ├── app/api/routes/health.py     # GET /health
│   ├── app/api/routes/capabilities.py  # GET /api/v1/capabilities
│   └── tests/
├── docs/backend-api.md              # HTTP API 契约（参考用，非第一阶段必须）
├── UI/
│   ├── interaction.md               # 产品交互需求
│   └── nju-timenote.pen             # UI 设计稿
└── src/nju_timenote/                # Flutter 前端
    ├── lib/app/providers.dart       # 依赖注入（所有 Repository 在此替换）
    └── lib/features/
        ├── timetable/               # 课表
        ├── todos/                   # 待办
        ├── settings/                # 设置
        └── home/                    # 首页
```

**核心原则：本地优先（local-first）**。课程、待办、标签、设置等用户数据默认只保存在设备本地。远程后端只承担必须联网的可选能力，远程服务不可用时 App 核心功能必须仍可正常使用。

---

## 2. 当前已完成的工作

### 2.1 后端（已就绪）

| 完成项 | 文件 | 说明 |
|--------|------|------|
| FastAPI 项目骨架 | `backend/app/main.py` | 支持生产环境关闭 `/docs`、TrustedHost 中间件 |
| 配置系统 | `backend/app/core/config.py` | Pydantic Settings，读取 `.env`（前缀 `NJUT_`） |
| 健康检查 | `backend/app/api/routes/health.py` | `GET /health` → `{"data": {"status": "ok"}}` |
| 能力声明 | `backend/app/api/routes/capabilities.py` | `GET /api/v1/capabilities` → 声明 local-first 策略 |
| 测试与检查 | `pyproject.toml` | Pytest + Ruff 配置，当前 3 个测试通过 |

没有数据库、没有 ORM、没有用户认证。这是正确的——第一阶段不需要。

### 2.2 前端（已就绪）

| 完成项 | 说明 |
|--------|------|
| 全部页面 UI | 首页、课表、待办、设置、搜索、批量操作、下一件事推荐、大目标拆分 |
| 状态管理 | Riverpod AsyncNotifier + Repository 模式 |
| 交互 | 完整的产品交互（见 `UI/interaction.md`） |

**关键问题：前端所有数据来自内存 Mock Repository，App 重启后数据全部丢失，没有接入本地数据库。**

---

## 3. 后端需要完成的三阶段工作

### 第一阶段：本地持久化（当前优先）

**这部分主要是前端工作，但需要你理解并在 Provider 层完成对接。**

需要创建的本地数据库表（SQLite via Drift）：

| 表名 | 用途 | 对应前端领域模型 |
|------|------|-----------------|
| `courses` | 课程及教学周规则 | `Course` (`timetable/models/course.dart`) |
| `todos` | 待办主体 | `TodoItem` (`todos/domain/todo.dart`) |
| `tags` | 本地标签库 | 标签名称列表 |
| `todo_tags` | 待办与标签的多对多 | 关联表 |
| `semester_settings` | 学期开学日期 | `SemesterSettings` (`settings/models/settings.dart`) |
| `period_times` | 节次时间 | `PeriodTime` (`settings/models/settings.dart`) |
| `search_history` | 本地搜索历史 | 搜索关键词列表 |

需要实现的 Repository（实现现有接口，替换 Mock）：

| Repository | 对应接口文件 | 当前 Mock 实现 |
|------------|-------------|---------------|
| `LocalCourseRepository` | `timetable/repositories/course_repository.dart` | `MockCourseRepository`（同文件内） |
| `LocalTodoRepository` | `todos/domain/todo_repository.dart` | `MockTodoRepository`（`todos/data/mock_todo_repository.dart`） |
| `LocalSettingsRepository` | `settings/repositories/settings_repository.dart` | `MockSettingsRepository`（同文件内） |

替换位置在 `src/nju_timenote/lib/app/providers.dart`：

```dart
// 当前（第 13-23 行）：
final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => MockCourseRepository(),          // → 改为 LocalCourseRepository
);
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => MockSettingsRepository(),        // → 改为 LocalSettingsRepository
);
final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => MockTodoRepository(),            // → 改为 LocalTodoRepository
);
```

完成标准：App 离线运行时可以完整使用课程、待办、标签、设置和规则推荐功能，重启后数据不丢失。

### 第二阶段：远程临时处理能力

**这是你作为后端开发者的核心工作。**

#### 2.1 基础设施（`B-CORE` 系列）

在实现第一个真实远程功能前必须完成：

- 统一响应/错误格式（`backend-api.md` 约定结构）
- 请求 ID 追踪 + 日志脱敏（禁止记录截图、待办正文）
- CORS 限制（仅允许预期来源）
- 限流 + 文件大小限制 + 滥用防护
- 临时文件生命周期管理（成功/失败/超时/重启后自动清理）

#### 2.2 课表截图识别（`B-SHOT` 系列）

这是推荐优先实现的第一个远程能力——它确实需要服务端处理，且不依赖用户账号和数据库。

工作清单：

1. **确认产品规则**：支持格式（PNG/JPEG）、最大文件大小、同步返回还是异步任务、识别失败是否允许手动修正
2. **设计上传接口**：`multipart/form-data` 接收真实图片（不是当前 API 文档中的 fileName/mimeType），可选携带学期周数、节次设置等辅助信息
3. **实现上传安全校验**：校验真实文件类型（magic bytes）、文件大小、图像尺寸、可解码性，不信任文件名和 MIME 类型
4. **对接识别引擎**：云 OCR 或视觉大模型，封装在内部接口后面以便替换
5. **结构化返回课程候选**：课程名称、教师、地点、周次规则、教学周、节次，不确定字段带置信度
6. **临时文件清理**：原始图片和中间内容按策略自动删除，不保存到数据库
7. **Flutter 端配合**：上传前展示隐私提示，用户确认候选课程后才写入本地数据库

#### 2.3 可选 AI 能力（`B-AI` 系列）

在截图识别完成后，根据产品需求逐步实现：

- 一句话解析创建待办（自然语言 → 结构化 `TodoDraft`）
- AI 推荐下一件事（替代当前规则推荐）
- AI 大目标拆分

所有 AI 请求必须：用户主动触发、前端明确告知发送的数据范围、服务端不持久化请求内容。

### 第三阶段：用户主动启用的云能力

**未来阶段，当前不实施。** 开始前需重新评估产品需求、隐私和成本。

- 客户端加密云备份
- 跨设备同步（需引入 PostgreSQL + Alembic + 账号系统）
- 临时分享链接

---

## 4. 前端现状：每项功能谁来做、做到什么程度

### 4.1 课程与课表

| 功能 | 前端状态 | 需要后端做什么 |
|------|---------|--------------|
| 按教学周查询课程 | UI 已完成，Mock 数据可用 | 无（本地计算） |
| 手动添加课程 | 完整表单 + 校验 + 提交逻辑 | 无（本地持久化） |
| 删除课程 | 长按 → 确认弹窗 → 删除 | 无（本地持久化） |
| 课表表格渲染 | 完整（7 天 × 12 节，冲突并排，颜色区分） | 无 |
| 截图识别导入 | UI 已完成，但 `importCoursesFromScreenshot()` 返回硬编码占位数据 | **第二阶段：实现截图识别 API** |

### 4.2 待办

| 功能 | 前端状态 | 需要后端做什么 |
|------|---------|--------------|
| 创建/查询/修改/删除 | 完整 UI + 表单校验 | 无（本地持久化） |
| 三种类型（duration/deadline/normal）| 完整，类型切换自动清空无关字段 | 无 |
| 标记完成 | 完成按钮 + 状态更新 | 无 |
| 批量删除/完成 | 批量选择 + 确认弹窗（完成跳过 duration） | 无 |
| 筛选（日期/类型/状态/标签）| 右侧边栏筛选 UI 完整 | 无（本地计算） |
| 搜索（大小写不敏感）| 搜索页 + 历史记录 UI 完整 | 无（本地计算） |
| 标签管理（预置 6 个 + 新增）| Tag 选择底部弹窗 + 新增对话框 | 无（本地持久化） |
| 下一件事推荐 | 三个滑块 + FutureBuilder 展示结果 | 暂不需要（本地规则推荐已完整），**第三阶段可选 AI 推荐** |
| 大目标拆分（3 步骤）| 设定目标 → 拆分小目标 → 预览确认，完整 | 无（本地事务创建） |
| 一句话智能创建 | UI 已完成，当前是假 AI（截取前 18 字 + 固定 deadline = 次日 23:59 + 固定标签"学习"） | **第二阶段可选：自然语言解析 API** |

### 4.3 设置

| 功能 | 前端状态 | 需要后端做什么 |
|------|---------|--------------|
| 学期开学日 | 只读展示"X 月 X 日" | 无（本地持久化） |
| 节次时间 | 显示"编辑"按钮，**onTap 为空** | 无（本地持久化，前端需补交互） |
| 本地备份 | 显示"立即备份"按钮，**onTap 为空** | 无（本地文件导出） |
| 导出/分享 | 显示"›"，**onTap 为空** | **第三阶段可选** |

---

## 5. 前端需要修改的地方（硬编码 & 未实现）

### 5.1 全局硬编码日期 ⚠️ 必须修改

App 中将 `DateTime(2026, 6, 19, 9, 41)` 作为"当前时间"硬编码在至少以下位置：

| 文件 | 位置 | 说明 |
|------|------|------|
| `mock_todo_repository.dart:267` | `_seedTodos()` | 种子数据的 `createdAt`/`updatedAt` |
| `mock_todo_repository.dart:275-343` | 种子待办的 `startAt`/`endAt`/`deadlineAt` | 所有时间字段 |
| `todos_screen.dart:165-166` | 筛选日期默认值 | `DateTime(2026, 6, 19)` |
| `todo_detail_screen.dart:230-235` | 切换类型时的默认时间 | `DateTime(2026, 6, 19, 18, 0)` 等 |
| `todo_detail_screen.dart:331-376` | 时间选择器的初始值 | 多处硬编码 |
| `goal_split_screen.dart:110-114` | 默认子目标日期 | `DateTime(2026, 6, 19)` 等 |
| `goal_split_screen.dart:254` | 新增子目标的默认日期 | `DateTime(2026, 6, 23)` |
| `home_screen.dart:349` | DDL 紧急程度判断 | 与固定日期比较 |
| `timetable_grid.dart:166-174` | 课表头部日期 | `04/06` ~ `04/12` 硬编码 |
| `course_repository.dart:100` | 种子课程时间 | `DateTime(2026, 4, 1)` |

**建议**：实现本地 Repository 时，将所有硬编码日期替换为 `DateTime.now()` 或基于 `semesterStartDate` 计算的实际日期。种子数据的时间戳统一使用"当前时间"。

### 5.2 搜索历史 ⚠️ 未进入 Repository

`TodosState` 中硬编码初始值：
```dart
this.searchHistory = const ['dlco', '作业', '考试', '数据结构', '会议'],
```

搜索历史的增删由 `TodosController` 在内存中管理（`providers.dart:126-142`），从未调用 Repository 方法持久化。当前的 `TodoRepository` 接口中**没有搜索历史相关方法**。

**需要做的事**：
- 在 `TodoRepository` 接口中增加 `fetchSearchHistory()` / `clearSearchHistory()` 方法，或在 Provider 层直接从 `search_history` 表读写
- 将 `TodosState.searchHistory` 初始值从硬编码改为从 Repository 加载

### 5.3 截图导入 ⚠️ 硬编码占位数据

`MockCourseRepository.importCoursesFromScreenshot()` 返回两条固定的假课程（"软件工程"和"人工智能导论"），不涉及任何真实图片处理。

前端 `ScreenshotCourseScreen` 的交互也只是点击"已选择课表截图"模拟选择，没有真正调用文件选择器或上传图片。

**需要做的事（第二阶段）**：
- 前端：改为真实文件选择器（`file_picker` 或 `image_picker`），上传 `multipart/form-data` 到后端截图识别接口
- 后端：实现识别 API，返回结构化课程候选

### 5.4 一句话智能创建待办 ⚠️ 假 AI

`todos_screen.dart:349-363` 中的 `showCreateTodoSheet` 的"智能创建"按钮实际上只是：
```dart
TodoDraft(
  title: text.length > 18 ? text.substring(0, 18) : text,  // 截断
  content: text,
  kind: TodoKind.deadline,
  deadlineAt: DateTime(2026, 6, 20, 23, 59),  // 固定日期
  priority: 4,
  tags: const ['学习'],  // 固定标签
)
```

**需要做的事（第二阶段可选）**：替换为调用后端自然语言解析 API，返回结构化的 `TodoDraft`。

### 5.5 设置页面 onTap 空壳 ⚠️

三个按钮完全没有实现：

| 按钮 | 文件位置 | 需要做的事 |
|------|---------|-----------|
| "节次时间 → 编辑" | `settings_screen.dart:29` | 第一阶段：实现节次编辑页 |
| "本地备份 → 立即备份" | `settings_screen.dart:51` | 第一阶段：导出 SQLite 文件到用户选择路径 |
| "导出 / 分享" | `settings_screen.dart:52` | 第三阶段 |

### 5.6 课程种子数据 ID ⚠️

`MockCourseRepository._seedCourses()` 使用固定短 ID（`c1` ~ `c12`），而 `LocalCourseRepository` 应使用 `course-<UUID v4>` 格式。如果后续实现同步，固定短 ID 会导致多设备主键冲突。

---

## 6. Repository 接口完整方法清单

以下列出三个 Repository 接口的全部方法，以及每个方法在后端各阶段的归属：

### CourseRepository

| 方法 | 参数 | 第一阶段 | 第二阶段 | 第三阶段 |
|------|------|---------|---------|---------|
| `fetchCourses` | `week: int` | 本地 SQLite 查询 | - | - |
| `addCourse` | `CourseDraft` | 本地 SQLite 写入 | - | - |
| `deleteCourse` | `courseId: String` | 本地 SQLite 删除 | - | - |
| `importCoursesFromScreenshot` | 无 | - | 调用后端识别 API | - |

### TodoRepository

| 方法 | 参数 | 第一阶段 | 第二阶段 | 第三阶段 |
|------|------|---------|---------|---------|
| `fetchTodos` | `TodoFilter` | 本地 SQLite 查询+筛选 | - | - |
| `searchTodos` | `String query` | 本地 SQLite 搜索 | - | - |
| `createTodo` | `TodoDraft` | 本地 SQLite 写入 | - | - |
| `updateTodo` | `todoId, TodoPatch` | 本地 SQLite 更新 | - | - |
| `deleteTodo` | `todoId` | 本地 SQLite 删除 | - | - |
| `completeTodo` | `todoId` | 本地 SQLite 更新 | - | - |
| `batchDelete` | `Set<String>` | 本地 SQLite 批量删除 | - | - |
| `batchComplete` | `Set<String>` | 本地 SQLite 批量更新（跳过 duration） | - | - |
| `fetchTags` | 无 | 本地 SQLite 查询 | - | - |
| `addTag` | `String name` | 本地 SQLite 写入 | - | - |
| `recommendTodos` | `RecommendationInput` | 本地规则推荐（照搬 Mock 逻辑） | 可选：调用 AI 推荐 | - |
| `createGoalSplitTodos` | `GoalSplitDraft` | 本地 SQLite 事务写入 | - | - |

### SettingsRepository

| 方法 | 参数 | 第一阶段 | 第二阶段 | 第三阶段 |
|------|------|---------|---------|---------|
| `fetchSemesterSettings` | 无 | 本地 SQLite 查询 | - | - |
| `backup` | 无 | 本地文件导出 | - | 可选：加密云备份 |
| `exportData` | 无 | 本地文件导出 | - | 可选：分享链接 |

---

## 7. 关键业务规则速查

实现本地 Repository 时必须遵守：

- **排序**：未完成在前 → 已完成在后；每组内 `deadlineAt ?? startAt` 升序；无时间的在最后
- **批量完成**：跳过 `duration` 类型待办
- **标签**：创建/更新待办时，携带不存在的标签则自动加入标签库
- **筛选**：`deadlineAt ?? startAt` 做日期匹配，标签使用"任意匹配"（OR）
- **大目标拆分**：全部子目标在同一事务中创建，deadline = 计划日期 23:59，默认优先级 4，默认标签"学习"
- **颜色**：课程颜色根据名称稳定计算（不要随机），首次生成后持久化
- **数据校验**：课程 name/location 非空、dayOfWeek 1-7、节次 1-12、教学周 1-25、start ≤ end；待办 title 非空、priority 0-5、duration 需 startAt+endAt 且 start<end、deadline 需 deadlineAt

---

## 8. 推荐执行顺序

```
现在 → 第一阶段
  1. 在 Flutter 中引入 Drift + SQLite 依赖（pubspec.yaml）
  2. 定义数据库表（app_database.dart）+ 生成代码（build_runner）
  3. 实现 LocalCourseRepository → 替换 MockCourseRepository
  4. 实现 LocalTodoRepository → 替换 MockTodoRepository
  5. 实现 LocalSettingsRepository → 替换 MockSettingsRepository
  6. 将所有硬编码日期替换为 DateTime.now() 或学期相关计算
  7. 将搜索历史接入 Repository/数据库
  8. 实现设置页面三个空壳按钮
  9. 实现本地备份与恢复（SQLite 文件导出）
  完成标准：App 离线可用，重启数据不丢

→ 第二阶段
  10. 实现 B-CORE 基础设施（错误格式、日志、限流等）
  11. 实现课表截图识别 API
  12. 前端接入真实文件选择和上传
  完成标准：可拍照/选图 → 上传 → 识别 → 用户确认 → 写入本地

→ 第三阶段（未来）
  13. 按需实现 AI、同步、云备份、分享
```

---

## 9. 相关文档索引

| 文档 | 路径 | 说明 |
|------|------|------|
| 后端开发指南 | `backend/docs/backend-development-guide.md` | 业务规则、数据边界、架构建议 |
| HTTP API 契约 | `docs/backend-api.md` | 接口格式参考（第一阶段不直接使用） |
| 产品交互需求 | `UI/interaction.md` | 每个页面的完整交互说明 |
| UI 设计稿 | `UI/nju-timenote.pen` | Pencil 设计文件 |
