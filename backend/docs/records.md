# 变更记录

本文档记录 NJU Timenote 后端开发过程中的每一项变更。

---

## 2026-06-11

### 新增文档

- **`backend/docs/backend-implementation-roadmap.md`** — 后端实施路线图。梳理项目当前状态、三阶段工作内容、前端每项功能的实现程度、前端硬编码问题清单、Repository 接口完整方法清单、业务规则速查、推荐执行顺序。
- **`backend/docs/frontend-backend-contract.md`** — 前后端协作契约。定义前后端的不可变边界：核心原则、数据模型、HTTP API、业务规则、自由空间划分、协作策略建议。
- **`docs/frontend-api-contract.md`** — 前端 API 契约文档（给协作者）。自包含的接口文档：架构约定、11 个数据模型 JSON 定义、24 个 API 接口格式、9 条业务规则、接口实施状态表、前端对接 Check List。
- **`backend/docs/records.md`** — 本文档，变更记录。
- **`backend/docs/local-generated-files-and-cleanup.md`** — 本地生成文件与清理指南。记录开发/运行时在设备上产生的全部额外文件路径、风险级别、清理方式。

### 配置变更

- **`backend/pyproject.toml`** — 新增 `[tool.fastapi]` 配置，入口 `entrypoint = "app.main:app"`，支持 `fastapi dev` / `fastapi run` 命令。

### Phase 1：Flutter 本地持久化

#### 新增文件

- **`src/nju_timenote/lib/core/database/app_database.dart`** — Drift 数据库定义，7 张表（courses, todos, tags, todo_tags, semester_settings, period_times, search_history），schema v1，onCreate 自动写入 seed 数据。
- **`src/nju_timenote/lib/core/database/app_database.g.dart`** — build_runner 生成的 Drift 代码。
- **`src/nju_timenote/lib/features/timetable/data/local_course_repository.dart`** — LocalCourseRepository，实现 CourseRepository 接口，SQLite 持久化课程数据，支持周次筛选、同步墓碑删除。
- **`src/nju_timenote/lib/features/todos/data/local_todo_repository.dart`** — LocalTodoRepository，实现 TodoRepository 接口 + fetchSearchHistory/clearSearchHistory，支持筛选、排序、搜索、批量操作、事务、标签自动入库。
- **`src/nju_timenote/lib/features/settings/data/local_settings_repository.dart`** — LocalSettingsRepository，从 SQLite 读取学期设置和节次时间。
- **`src/nju_timenote/test/features/timetable/local_course_repository_test.dart`** — LocalCourseRepository 单元测试（5 个 case，使用内存数据库）。

#### 修改文件

- **`src/nju_timenote/pubspec.yaml`** — 新增依赖：drift, sqlite3_flutter_libs, path_provider, uuid（运行时），drift_dev, build_runner（开发时）。
- **`src/nju_timenote/lib/app/providers.dart`** — 新增 databaseProvider；courseRepositoryProvider/settingsRepositoryProvider/todoRepositoryProvider 全部从 Mock 切换为 Local 实现；TodosState.searchHistory 从硬编码改为从 Repository 加载。
- **`src/nju_timenote/lib/features/todos/domain/todo_repository.dart`** — 新增 fetchSearchHistory() 和 clearSearchHistory() 抽象方法。
- **`src/nju_timenote/lib/features/todos/data/mock_todo_repository.dart`** — 实现 fetchSearchHistory/clearSearchHistory，_searchHistory 初始值复用原硬编码数据。
- **`src/nju_timenote/test/widget_test.dart`** — 添加内存数据库注入（ProviderScope overrides），widget 测试不再依赖真实磁盘数据库。

#### 未修改的页面层

所有 Screen/Widget 文件**零改动**，Repository 接口契约保持不变，页面层透明切换。

### 前端补充完善

#### 新增文件

- **`src/nju_timenote/lib/features/settings/screens/period_editor_screen.dart`** — 节次时间编辑页。展示 12 节课的起止时间，点击时间弹出 TimePicker，保存按钮事务写入数据库。

#### 修改文件

- **`src/nju_timenote/lib/features/settings/repositories/settings_repository.dart`** — 新增 `updatePeriodTimes(List<PeriodTime>)` 抽象方法，`MockSettingsRepository` 和 `LocalSettingsRepository` 均实现。`backup()` 返回类型从 `Future<void>` 改为 `Future<String>`（返回备份路径）。
- **`src/nju_timenote/lib/features/settings/data/local_settings_repository.dart`** — 实现 `updatePeriodTimes()`（事务内批量替换）；实现 `backup()`（复制 SQLite 文件到 Downloads 目录）。
- **`src/nju_timenote/lib/features/settings/screens/settings_screen.dart`** — "节次时间 → 编辑" 接入 PeriodEditorScreen 路由；"本地备份 → 立即备份" 调用 backup() 并 SnackBar 提示路径。
- **`src/nju_timenote/lib/app/app.dart`** — 注册 PeriodEditorScreen 路由。
- **`src/nju_timenote/lib/app/routes.dart`** — 新增 `periodEditor` 路由常量。
- **`src/nju_timenote/lib/core/database/app_database.dart`** — `_seed()` 新增 5 条种子待办数据（duration ×1、deadline ×2、normal ×1、done ×1），含标签关联。
- **`src/nju_timenote/lib/features/home/home_screen.dart`** — DDL 紧急判断用 `DateTime.now()` 替代硬编码日期。
- **`src/nju_timenote/lib/features/todos/presentation/screens/todos_screen.dart`** — 筛选日期默认值、智能创建 deadline 改为基于 `DateTime.now()`。
- **`src/nju_timenote/lib/features/todos/presentation/screens/todo_detail_screen.dart`** — `_pickDuration()` / `_pickDeadline()` 中的初始时间和硬编码日期全部替换为 `DateTime.now()`。
- **`src/nju_timenote/lib/features/todos/presentation/screens/goal_split_screen.dart`** — 最终 DDL 默认值、子目标默认日期、DatePicker 边界均改为动态计算。
