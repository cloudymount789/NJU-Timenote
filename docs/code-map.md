# NJU Timenote 代码地图

本地图记录 Flutter 前端结构和后续 Agent 的常用修改入口。前端工程根目录为 `frontend/`。

## App 入口

- `frontend/lib/main.dart`：启动 `TimenoteApp`。
- `frontend/lib/app/app.dart`：根 `MaterialApp`、主题、路由接入和 `AppScope` repository 注入。
- `frontend/lib/app/router.dart`：命名路由和路由参数对象；使用通用 route 返回值承载详情、tag 选择、大目标拆分和学期详情等流程结果。

## 主题与设计 Token

- `frontend/lib/app/theme/app_theme.dart`：全局亮色主题和思源宋体优先字体族。
- `frontend/lib/app/theme/app_colors.dart`：来自 Pencil 原型的颜色 token。
- `frontend/lib/app/theme/app_spacing.dart`：间距 token。
- `frontend/lib/app/theme/app_shadows.dart`：卡片和浮层阴影。
- `frontend/assets/fonts/`：已放入 Source Han Serif SC 的 Regular、SemiBold、Bold 三个 OTF 字重及 OFL 许可证，并在 `frontend/pubspec.yaml` 注册。

## 通用组件

- `frontend/lib/core/widgets/gradient_page_scaffold.dart`：统一页面基底；顶部 225px 蓝紫粉柔和渐变，其余白底。
- `frontend/lib/core/widgets/app_header.dart`：页面标题/header。
- `frontend/lib/core/widgets/app_card.dart`：白色卡片和原型风格阴影。
- `frontend/lib/core/widgets/app_bottom_input_bar.dart`：快速挑选、一句话输入和搜索底部栏；支持紧凑尺寸，供首页等固定底栏场景使用。
- `frontend/lib/core/widgets/create_todo_sheet.dart`：创建待办底部浮层；支持一句话创建、手动创建和大目标拆分入口。
- `frontend/lib/core/widgets/app_icon_button.dart`：统一图标按钮封装。
- `frontend/lib/core/widgets/app_feedback.dart`：SnackBar 等轻量反馈入口。
- `frontend/lib/core/widgets/app_dialogs.dart`：确认弹窗和滚轮选择器壳。
- `frontend/lib/core/widgets/right_sidebar_shell.dart`：右侧侧栏壳。
- `frontend/lib/core/widgets/state_views.dart`：空态、加载态、错误态、禁用态。
- `frontend/lib/core/widgets/placeholder_page.dart`：历史/备用占位页面壳；当前主路由已指向真实页面，不依赖占位页。
- `frontend/lib/core/time/app_clock.dart`：统一当前时间来源；运行时使用系统时间，测试可注入 `FixedAppClock`，避免 UI/source 到处直接调用 `DateTime.now()`。

## 数据边界

- `frontend/lib/data/models/`：按接口契约形状建立的课程、待办、设置、推荐、大目标拆分模型；`course.dart` 已包含 `Course` 序列化、`CourseDraft`、所属学期 `semesterId`、取消显示周次 `canceledWeeks` 和周次匹配规则；`settings.dart` 已包含多个学期课表配置、课表归属、学年范围、春/秋学期类型、自动生成课表名称、开学日期、持续周数、创建/更新时间和上次选中学期；`todo.dart` 已包含 `TodoItem`、`TodoDraft`、`TodoPatch`、`TodoFilter`、PATCH 字段语义和筛选匹配。
- `frontend/lib/data/repositories/`：repository 接口和本地 repository 工厂；课程 repository 已支持按周查询、单条查询、下一节课计算、创建、更新、删除和课程名稳定颜色；待办 repository 已支持查询、筛选、创建、更新、删除、完成、取消完成、完成状态切换、手动排序、智能排序、批量删除、批量完成和基础搜索；tag repository 支持查询、新增、删除，删除 tag 时通过待办 source 从所有已有待办移除同名 tag；`AppRepositories.changes` 是 repository 级刷新信号，课程/待办/tag 删除/快速创建/大目标拆分写入成功后触发，首页、待办页等页面应监听后重新查询 repository；`RepositoryFactory.persistent(clock)` 用 `shared_preferences` 初始化设备本地 JSON 存储，是 App 运行入口；`RepositoryFactory.local(clock)` 保留为纯内存 fake，供单元测试和 widget 测试使用；`QuickTodoRepository` 封装一句话创建边界。
- `frontend/lib/data/sources/local/`：本地 source；`local_json_store.dart` 是 `shared_preferences` JSON 快照适配层；`LocalCourseSource` 持久化课程列表、单周删除例外和课程名稳定颜色映射，按课程所属学期与学期持续周数筛选课程，并按当前日期计算当前教学周/下一节课和提供 `defaultPeriodTimes` 节次时间配置；`LocalTodoSource` 持久化待办列表、默认/手动/智能排序状态、手动顺序、重复周期完成记录和计数器，并负责契约排序、筛选、重复规则投影、7 天已完成记录清理、duration 自动完成、批量规则和 tag 删除后的待办引用清理；`LocalTagSource` 持久化预置 tag 与新增 tag，支持删除 tag；`LocalSettingsSource` 读取/写入多个学期课表设置快照，仅在首次无本地设置时创建 `2026-03-02` 开学、持续 `16` 周、课表归属为 `我` 的默认课表，用户删除全部课表后不会自动重建，校验持续周数范围，不限制不同课表的日期周范围重叠；`LocalRecommendationSource` 用本地规则生成推荐，`LocalGoalSplitSource` 将小目标批量生成 deadline 待办，并为每条小目标只添加一个“大目标 tag”（由大目标名称生成，超过 12 个字符截断为前 12 个字符 + `...`），不再默认添加 `学习`。
- `frontend/lib/data/sources/mock/`：mock 边界占位；默认不启用 mock 数据。
- `frontend/lib/data/sources/remote/`：未来后端边界占位；UI 不得直接调用。

## 功能页面

- `frontend/lib/features/home/home_page.dart`：任务 1 首页和主导航；首页通过 repository 读取真实的下一节课、下一件事和 DDL 提醒，监听 `AppRepositories.changes` 并支持下拉刷新；底部一句话输入栏通过 `Stack` 固定在屏幕底部上层。
- `frontend/lib/features/settings/settings_page.dart`：设置入口，包含课表与作息、数据与分享分区；“管理学期课表”进入独立管理路由。
- `frontend/lib/features/settings/semester_pages.dart`：学期课表管理列表和详情页；支持查看、新增、编辑、长按删除、课表归属、学年范围/春秋学期/开学日期/持续周数设置；课表名称由归属、学年范围和学期类型自动生成，在详情白色卡片左上角作为标题展示，不再手动编辑。
- `frontend/lib/features/schedule/schedule_page.dart`：课表网格、按当前选中学期开学日计算默认当前周、学期切换、下拉刷新、周切换、周几日期、周数限制在 `1..持续周数`、跨上午/下午/晚间切割、冲突排列、点击编辑、长按选择删除范围。
- `frontend/lib/features/schedule/add_schedule_page.dart`：添加课表入口页。
- `frontend/lib/features/schedule/manual_course_page.dart`：手动添加/编辑课程表单、添加至学期、随学期持续周数联动的周次选择、节次选择和校验。
- `frontend/lib/features/schedule/screenshot_course_page.dart`：截图添加课程流程壳，当前提示识别服务未接入。
- `frontend/lib/features/todo/todo_list_page.dart`：待办列表、空态、下拉刷新、筛选侧栏、批量模式、拖拽排序、三种待办行、底部输入栏入口；右上角为批量编辑/筛选/手动添加待办，智能排序入口在列表大卡片左上区域。
- `frontend/lib/features/todo/todo_detail_page.dart`：待办新建/编辑详情页、重复优先的类型切换、一次性日期时间选择、重复周几/时间选择、半星优先级、删除确认。
- `frontend/lib/features/todo/todo_tag_page.dart`：tag 多选、新增 tag 弹窗和长按删除 tag；删除前二次确认，确认后从 tag 库与所有已有待办中移除该 tag 引用。
- `frontend/lib/features/todo/todo_search_page.dart`：待办搜索、历史、清空历史确认、结果列表。
- `frontend/lib/features/recommendation/next_thing_page.dart`：下一件事状态滑杆和推荐结果页。
- `frontend/lib/features/goal_split/goal_split_page.dart`：大目标拆分三步流程和确认生成。

## 测试位置

- `frontend/test/course_repository_test.dart`：课程 model/source、课表布局和节次显示测试。
- `frontend/test/todo_repository_test.dart`：待办排序、筛选、完成限制、重复规则、tag 和排序测试。
- `frontend/test/local_persistence_test.dart`：通过 `shared_preferences` mock 模拟 App 重启，覆盖课程、待办、tag、筛选、更新、删除和重复完成记录的本地持久化。
- `frontend/test/task4_flows_test.dart`：一句话创建、搜索、推荐和大目标拆分数据流测试。
- `frontend/test/widget_test.dart`：首页、设置、创建浮层、待办详情/tag、推荐添加等 widget 流程测试。

## 常见修改入口

- 新增或修改路由：先看 `frontend/lib/app/router.dart`，再看目标 feature 页面。
- 调整全局颜色、阴影、圆角、字号或字体：改 `frontend/lib/app/theme/` 和对应通用组件。
- 新增业务数据访问：先定义或扩展 `frontend/lib/data/repositories/`，再通过 source 实现，并在 `RepositoryFactory` 注入。
- 按原型新增页面：优先复用 `GradientPageScaffold`、`AppHeader`、`AppCard` 和状态视图。
- 修改课表：优先看 `frontend/lib/features/schedule/`、`frontend/lib/data/models/course.dart`、`frontend/lib/data/sources/local/local_course_source.dart`。
- 修改待办核心：优先看 `frontend/lib/features/todo/`、`frontend/lib/data/models/todo.dart`、`frontend/lib/data/sources/local/local_todo_source.dart`、`frontend/lib/data/sources/local/local_tag_source.dart`。
- 修改创建/搜索/推荐/目标拆分：看 `frontend/lib/core/widgets/create_todo_sheet.dart`、`frontend/lib/features/todo/todo_search_page.dart`、`frontend/lib/features/recommendation/next_thing_page.dart`、`frontend/lib/features/goal_split/goal_split_page.dart`、`frontend/lib/data/sources/local/local_recommendation_source.dart`、`frontend/lib/data/sources/local/local_goal_split_source.dart`。
- 运行检查：进入 `frontend/` 后执行 `dart format lib test`、`flutter analyze`、`flutter test`。

## 边界

- 不要擅自修改 `docs/frontend-backend-contract.md`。
- UI Widget 不直接访问 HTTP、数据库、文件或平台存储。
- 不要在 UI Widget 中散落假业务数据。需要演示或测试数据时，只能集中放在 mock/fake source。
