# 前后端协作契约

本文档定义后端与前端（当前 Flutter 原型 / 协作者重写版）之间的不可变边界。后端只认这份契约，前端可以随意换技术栈、架构、UI，只要遵守以下约定就不会冲突。

---

## 1. 核心原则

1. **本地优先**：课程、待办、标签、设置默认保存在用户设备上。后端不存储用户业务数据。
2. **后端可选**：后端不可用时，App 核心功能（增删改查、筛选、排序、推荐）必须仍可使用。
3. **API 即契约**：前后端唯一共同依赖的是 HTTP API 格式。Flutter 端的 Repository 接口、Riverpod Provider、Widget 代码均不是契约的一部分。

---

## 2. 不可变的数据模型

以下模型是前后端通信的 **JSON 格式约定**。字段名、类型、枚举值不可随意修改。添加新字段可以（前端应忽略未知字段），但已有字段的语义不能变。

### 2.1 Course

```json
{
  "id": "course-100",
  "name": "数据结构",
  "teacher": "王老师",
  "location": "机房A",
  "note": "实验课",
  "dayOfWeek": 3,
  "startPeriod": 5,
  "endPeriod": 6,
  "weekRule": "all",
  "startWeek": 1,
  "endWeek": 16,
  "colorKey": "pink",
  "source": "manual",
  "createdAt": "2026-04-09T09:41:00+08:00",
  "updatedAt": "2026-04-09T09:41:00+08:00"
}
```

| 约束 | 值 |
|------|----|
| `dayOfWeek` | 1-7 |
| `startPeriod` / `endPeriod` | 1-12, startPeriod ≤ endPeriod |
| `startWeek` / `endWeek` | 1-25, startWeek ≤ endWeek |
| `weekRule` | `"all"` / `"odd"` / `"even"` |
| `source` | `"manual"` / `"screenshot"` / `"sample"` |
| `colorKey` | 按课程名稳定生成；课程名首次出现时可随机分配，之后同课程名 = 同颜色 |

### 2.2 TodoItem

```json
{
  "id": "todo-1",
  "title": "数据结构实验报告",
  "content": "完成实验三并提交到教学网",
  "location": "线上提交",
  "kind": "deadline",
  "startAt": null,
  "endAt": null,
  "deadlineAt": "2026-06-19T23:59:00+08:00",
  "priority": 4.5,
  "tags": ["作业", "考试"],
  "repeatRule": "once",
  "status": "open",
  "createdAt": "2026-04-09T09:41:00+08:00",
  "updatedAt": "2026-04-09T09:41:00+08:00"
}
```

| 约束 | 值 |
|------|----|
| `kind` | `"duration"` / `"deadline"` / `"normal"` |
| `priority` | 0.0 - 5.0（支持半星） |
| `status` | `"open"` / `"done"` |
| `repeatRule` | `"once"` / `"daily"` / `"weekly"` / `"biweekly"` |
| `kind = "duration"` | 必须提供 `startAt` 和 `endAt`，且 `startAt < endAt` |
| `kind = "deadline"` | 必须提供 `deadlineAt` |
| `kind = "normal"` | `startAt`、`endAt`、`deadlineAt` 均应为 `null` |
| `repeatRule != "once"` | 不生成未来实例；`deadlineAt` 或 `startAt`/`endAt` 仅作为重复时间锚点：`daily` 使用时间部分，`weekly`/`biweekly` 使用周几 + 时间部分 |

### 2.3 TodoDraft（创建待办请求体）

```json
{
  "title": "整理课堂笔记",
  "content": "把今天三节课的重点整理成思维导图",
  "location": "图书馆",
  "kind": "normal",
  "startAt": null,
  "endAt": null,
  "deadlineAt": null,
  "priority": 3.5,
  "tags": ["学习", "作业"],
  "repeatRule": "once"
}
```

### 2.4 TodoPatch（更新待办请求体，所有字段可选）

```json
{
  "kind": "normal",
  "startAt": null,
  "endAt": null,
  "deadlineAt": null
}
```

**PATCH 语义**：字段省略 = 保持原值不变；字段显式传 `null` = 清空该字段。

### 2.5 TodoFilter（筛选参数，作为 GET Query String）

| 参数 | 格式 | 说明 |
|------|------|------|
| `date` | `2026-06-19` | 日期筛选，用 `deadlineAt ?? startAt` 匹配 |
| `kind` | `duration,deadline,normal` | 逗号分隔，多选 |
| `status` | `open,done` | 逗号分隔，多选 |
| `tag` | `作业,考试` | 逗号分隔，**任意匹配**（OR） |
| `onlyDeadline` | `true` / `false` | 仅返回有截止时间的待办 |

### 2.6 RecommendationInput（推荐请求体）

```json
{
  "mood": 52,
  "willingness": 68,
  "anxiety": 35
}
```

三个值范围均为 1-100。

### 2.7 TodoRecommendation（推荐响应）

```json
{
  "section": "不得不做的事",
  "title": "数据结构实验报告",
  "reason": "虽然你现在可能不是很想做事情，但是ddl马上要到啦...",
  "todoId": "todo-1",
  "canAdd": false
}
```

### 2.8 GoalSplitDraft（大目标拆分请求体）

```json
{
  "title": "高数期末复习",
  "note": "复习范围：第1-8章",
  "finalDeadline": "2026-06-25T23:59:00+08:00",
  "subtasks": [
    { "title": "整理第一章笔记", "plannedDate": "2026-06-19" },
    { "title": "完成习题 1-20", "plannedDate": "2026-06-20" }
  ]
}
```

每个子目标的 deadline = `plannedDate` 当天 23:59。

### 2.9 SemesterSettings & PeriodTime

```json
{
  "semesterStartDate": "2026-09-01",
  "periods": [
    { "period": 1, "start": "08:00", "end": "08:50" },
    { "period": 2, "start": "09:00", "end": "09:50" }
  ]
}
```

`period` 范围 1-12，`start`/`end` 格式 `HH:mm`。

---

## 3. 不可变的 HTTP API

基础路径：`/api/v1`
Content-Type：`application/json`
时间戳：ISO 8601 带时区
IDs：客户端生成的全局唯一字符串（如 `course-<UUID>`、`todo-<UUID>`）

### 3.1 通用错误格式

```json
{
  "error": {
    "code": "validation_error",
    "message": "course name is required"
  }
}
```

| HTTP 状态码 | 场景 |
|------------|------|
| `200` | 查询或修改成功 |
| `201` | 创建成功 |
| `204` | 删除成功（无响应体） |
| `400` | 请求格式/参数错误 |
| `404` | 资源不存在 |
| `409` | 唯一性/状态冲突 |
| `422` | 业务字段校验失败 |
| `500` | 服务端错误 |

### 3.2 课程接口

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/api/v1/courses?week=6` | 按教学周查询课程 |
| `POST` | `/api/v1/courses` | 创建课程 |
| `DELETE` | `/api/v1/courses/{courseId}` | 删除课程 |
| `POST` | `/api/v1/courses/imports/screenshot` | 截图识别导入（**第二阶段**，使用 `multipart/form-data`） |

### 3.3 待办接口

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/api/v1/todos?date=X&kind=X&status=X&tag=X&onlyDeadline=X` | 筛选查询待办 |
| `POST` | `/api/v1/todos` | 创建待办 |
| `PATCH` | `/api/v1/todos/{todoId}` | 更新待办 |
| `DELETE` | `/api/v1/todos/{todoId}` | 删除待办 |
| `POST` | `/api/v1/todos/{todoId}/complete` | 标记完成 |
| `POST` | `/api/v1/todos/batch/delete` | 批量删除 |
| `POST` | `/api/v1/todos/batch/complete` | 批量完成（跳过 `duration` 类型） |
| `GET` | `/api/v1/todos/search?q=关键词` | 搜索（大小写不敏感，搜 title/content/location/tags） |
| `POST` | `/api/v1/todos/recommendations` | 下一件事推荐 |
| `POST` | `/api/v1/todos/goal-splits` | 大目标拆分创建 |

### 3.4 标签接口

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/api/v1/todo-tags` | 获取所有标签 |
| `POST` | `/api/v1/todo-tags` | `{"name": "复习"}` 新增标签 |

### 3.5 设置接口

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/api/v1/settings/semester` | 获取学期开学日 |
| `GET` | `/api/v1/settings/periods` | 获取节次时间 |
| `PUT` | `/api/v1/settings/semester` | 修改学期（待实现） |
| `PUT` | `/api/v1/settings/periods` | 修改节次（待实现） |
| `POST` | `/api/v1/settings/backup` | 创建备份 |
| `POST` | `/api/v1/exports` | 创建分享导出 |

### 3.6 服务接口

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/health` | 健康检查 |
| `GET` | `/api/v1/capabilities` | 服务能力声明 |

---

## 4. 不变的业务规则

以下规则前后端必须一致实现，否则会出现行为差异：

### 4.1 待办排序

1. 未完成待办排在已完成待办之前
2. 每组内按 `deadlineAt ?? startAt` 升序排列
3. 没有时间的待办（两个值都为 null）排在有时间待办的**最后**

### 4.2 批量完成

`duration` 类型待办被批量完成时**必须跳过**，不被标记为 done。

### 4.3 标签自动入库

创建或更新待办时，如果携带了尚不存在的标签，自动将其加入标签库。

### 4.4 大目标拆分

- 所有子目标在一个事务中创建
- 每个子目标 = `deadline` 类型待办，deadline = `plannedDate` 当天 23:59
- 默认优先级 4，默认标签 `"学习"`
- 任意一条失败，全部回滚

### 4.5 颜色生成

课程颜色由课程名称**稳定生成**。当课程名第一次出现时，可以从前端合规色板中随机分配一个 `colorKey`；一旦分配完成，必须保存“课程名 -> colorKey”的映射，之后同一课程名在不同教学周保持相同颜色。

### 4.6 预置标签

首次使用时预置六个标签：`考试`、`作业`、`讲座`、`会议`、`生活`、`学习`

### 4.7 课程周次筛选

`GET /courses?week=N` 只返回 `startWeek ≤ N ≤ endWeek` 且 `weekRule` 匹配的课程：
- `all`：所有周
- `odd`：N 为奇数
- `even`：N 为偶数

### 4.8 重复待办

`repeatRule != "once"` 的待办是**重复规则/模板**，不是预生成的一组未来待办。前端或后端查询列表时，按当前日期或筛选日期把模板投影成当前周期应出现的 1 条待办：

- `daily`：每天 1 个周期，使用 `deadlineAt` 或 `startAt`/`endAt` 的时间部分。
- `weekly`：每周 1 个周期，使用 `deadlineAt` 或 `startAt`/`endAt` 的周几 + 时间部分。
- `biweekly`：每两周 1 个周期，使用 `deadlineAt` 或 `startAt`/`endAt` 的周几 + 时间部分，并以模板时间所在周作为双周锚点。
- 删除重复待办 = 删除整条重复规则，不能只删除某个投影实例。
- 完成重复 `deadline` / `normal` 待办时，只记录当前周期完成；下一个周期仍按规则显示。
- 重复 `deadline` 待办当前周期未完成且超时后，仍保持未完成；进入下一个周期后继续显示下一个周期的投影待办。
- 重复 `duration` 待办在对应周期的结束时间后自动记录当前周期完成。
- 重复完成记录只保存 7 天；清理完成记录时不得删除重复规则本身。

---

## 5. 前后端各自的自由空间

### 前端可以自由改变的

- UI 框架（Flutter / React Native / 原生）
- 状态管理方案（Riverpod / BLoC / Redux / 自研）
- 本地数据库方案（Drift / Hive / Isar / 无数据库）
- 页面布局、路由、导航结构
- 任何 `lib/` 下的 Dart 代码

### 后端可以自由改变的

- 数据库选型（PostgreSQL / SQLite / 无数据库）
- 框架版本、中间件、部署方式
- 识别引擎供应商
- 任何 `backend/app/` 下的 Python 代码

### 唯一不可变的是

**本文档第 2 节（数据模型）、第 3 节（HTTP API）、第 4 节（业务规则）。**

---

## 6. 协作策略建议

当前阶段（第一阶段 = 本地持久化），后端 API 还不承载真实的 CRUD 流量。前端和后端可以完全并行：

- **协作者重写前端**：只要遵守本文档的模型 + API 格式，后端可以无缝对接。建议先用硬编码数据做 UI，待后端 API 就绪后替换 HTTP 层。
- **你开发后端**：从第二阶段（截图识别）开始，提供真实的 API endpoint。当前 API 契约以本文档为准；如后续新增 `docs/backend-api.md`，需要与本文档同步后再共同作为依据。

如果协作者发现 API 设计有问题（字段缺失、格式不合理），应该**先修改本文档**，双方确认后各自同步。

---

## 附录：当前 Flutter 实现与后端约束的差异记录

本附录只记录当前 Flutter 前端实现现状与上文契约/后端约束不一致或尚未对齐的地方，不改变上文契约本身。

1. **设备本地持久化已完成，但尚不是可迁移数据库**
   - 契约原则要求课程、待办、标签、设置默认保存在用户设备上。
   - 当前 App 运行入口使用 `RepositoryFactory.persistent()`，通过 `shared_preferences` JSON 快照保存课程、待办、标签、设置、课程颜色映射、排序状态和重复完成记录；纯内存 source 仅保留给测试。
   - 该实现满足当前本地优先阶段，但未来若字段结构变化较大，需要补数据版本和迁移策略。

2. **后端 HTTP API 尚未接入**
   - 契约定义了 `/api/v1` 下的课程、待办、标签、设置、服务能力等 HTTP API。
   - 当前 Flutter 通过 repository 调用本地 source，不发起 HTTP 请求；`remote/` 目录仍是未来后端边界占位。

3. **ID 生成格式不是契约建议的 UUID**
   - 契约建议客户端生成全局唯一字符串，例如 `course-<UUID>`、`todo-<UUID>`。
   - 当前课程 ID 使用 `course-${now.microsecondsSinceEpoch}`，待办 ID 使用 `todo-${now.microsecondsSinceEpoch}-${counter}`，不是 UUID 格式。

4. **大目标拆分默认 tag 与契约不一致**
   - 契约 4.4 写明大目标拆分默认标签为 `"学习"`。
   - 当前 Flutter 实现不再默认添加 `学习`，而是只为每个小目标添加一个“大目标 tag”：默认使用大目标名称，超过 12 个字符截断为前 12 个字符 + `...`。

5. **大目标拆分未实现显式事务/回滚机制**
   - 契约要求所有子目标在一个事务中创建，任意一条失败则全部回滚。
   - 当前 `LocalGoalSplitSource` 会先做基础校验，再逐条调用 `createTodo`；本地 JSON 快照实现中没有显式事务或失败回滚机制。

6. **TodoFilter 缺少 `onlyDeadline` 字段**
   - 契约 2.5 / 3.3 包含 `onlyDeadline=true/false` 查询参数。
   - 当前 `TodoFilter` 只有 `date`、`kinds`、`statuses`、`tags`，没有独立的 `onlyDeadline`；前端用 `kinds: [TodoKind.deadline]` 实现类似筛选。

7. **课程更新是前端本地扩展，契约 API 未定义对应接口**
   - 契约课程 API 目前只有按周查询、创建、删除和截图导入。
   - 当前 `CourseRepository` / `LocalCourseSource` 支持 `updateCourse`，用于本地编辑课程；若接后端，需要补充或确认课程更新 HTTP API。

8. **待办取消完成/切换完成是前端本地扩展**
   - 契约定义了 `POST /todos/{todoId}/complete`，未单独定义取消完成或 toggle API。
   - 当前 `TodoRepository` 支持 `reopenTodo` 与 `toggleTodoCompletion`，UI 中普通/DDL 待办可完成后取消完成。

9. **截图导入课程流程未接真实服务**
   - 契约定义 `POST /api/v1/courses/imports/screenshot`，第二阶段使用 `multipart/form-data`。
   - 当前截图添加课程页面是流程壳，只提示真实识别服务未接入，不会上传图片或写入课程。

10. **设置、备份、导出和服务能力接口未完整实现**
    - 契约定义了学期、节次、备份、导出、健康检查、服务能力等接口。
    - 当前 `LocalSettingsSource` 会读取/写入本地设置快照；首次使用时返回固定 `semesterStartDate: 2026-09-01` 和空 `periods`。课表显示使用前端内置默认节次时间；未实现可编辑节次设置、备份、导出、`/health`、`/api/v1/capabilities` 等能力。

11. **推荐逻辑为本地规则，不调用契约中的推荐 API**
    - 契约定义 `POST /api/v1/todos/recommendations`。
    - 当前 `LocalRecommendationSource` 根据本地未完成待办和输入滑杆用简单规则生成推荐；没有后端请求，也没有服务端推荐策略。

12. **部分 repository 查询能力是前端便利方法，不属于当前 HTTP 契约**
    - 当前前端有 `getTodoById`、`getNextTodo`、`getCourseById`、`getNextCourse` 等本地便利方法。
    - 上文 HTTP API 暂未定义这些单条查询或“下一项”接口；接入后端时需要由前端组合现有列表接口，或补充对应 API 契约。
