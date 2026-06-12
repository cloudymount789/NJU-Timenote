# NJU Timenote 代码地图

本地图记录 Flutter 前端结构和后续 Agent 的常用修改入口。前端工程根目录为 `frontend/`。

## App 入口

- `frontend/lib/main.dart`：启动 `TimenoteApp`。
- `frontend/lib/app/app.dart`：根 `MaterialApp`、主题、路由接入和 `AppScope` repository 注入。
- `frontend/lib/app/router.dart`：命名路由和路由参数对象。

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
- `frontend/lib/core/widgets/app_dialogs.dart`：确认弹窗和滚轮选择器壳。
- `frontend/lib/core/widgets/right_sidebar_shell.dart`：右侧侧栏壳。
- `frontend/lib/core/widgets/state_views.dart`：空态、加载态、错误态、禁用态。
- `frontend/lib/core/widgets/placeholder_page.dart`：后续任务用的占位页面壳。
- `frontend/lib/core/time/app_clock.dart`：统一当前时间来源；运行时使用系统时间，测试可注入 `FixedAppClock`，避免 UI/source 到处直接调用 `DateTime.now()`。

## 数据边界

- `frontend/lib/data/models/`：按接口契约形状建立的课程、待办、设置、推荐、大目标拆分模型；`course.dart` 已包含 `Course` 序列化、`CourseDraft` 和周次匹配规则；`todo.dart` 已包含 `TodoItem`、`TodoDraft`、`TodoPatch`、`TodoFilter`、PATCH 字段语义和筛选匹配。
- `frontend/lib/data/repositories/`：repository 接口和本地 repository 工厂；课程 repository 已支持按周查询、单条查询、创建、更新、删除和课程名稳定颜色；待办 repository 已支持查询、筛选、创建、更新、删除、完成、取消完成、完成状态切换、手动排序、智能排序、批量删除、批量完成和基础搜索；`RepositoryFactory.local(clock)` 负责把统一时间来源注入本地 source；`QuickTodoRepository` 封装一句话创建边界。
- `frontend/lib/data/sources/local/`：本地 source；`LocalCourseSource` 维护内存课程列表、课程名稳定颜色、下一节课计算和 `defaultPeriodTimes` 节次时间配置；`LocalTodoSource` 维护内存待办列表、契约排序、手动排序、智能排序、筛选、重复实例生成、duration 自动完成和批量规则，`LocalTagSource` 维护预置 tag 和新增 tag，`LocalRecommendationSource` 用本地规则生成推荐，`LocalGoalSplitSource` 将小目标批量生成 deadline 待办。
- `frontend/lib/data/sources/mock/`：mock 边界占位；默认不启用 mock 数据。
- `frontend/lib/data/sources/remote/`：未来后端边界占位；UI 不得直接调用。

## 功能页面

- `frontend/lib/features/home/home_page.dart`：任务 1 首页和主导航；首页为非滚动布局，底部一句话输入栏通过 `Stack` 固定在屏幕底部上层。
- `frontend/lib/features/settings/settings_page.dart`：最小设置入口，包含课表与作息、数据与分享分区。
- `frontend/lib/features/schedule/schedule_page.dart`：课表网格、周切换、周几日期、跨节/跨上午下午切割、冲突排列、点击编辑、长按删除。
- `frontend/lib/features/schedule/add_schedule_page.dart`：添加课表入口页。
- `frontend/lib/features/schedule/manual_course_page.dart`：手动添加/编辑课程表单、周次/节次选择和校验。
- `frontend/lib/features/schedule/screenshot_course_page.dart`：截图添加课程流程壳，当前提示识别服务未接入。
- `frontend/lib/features/todo/todo_list_page.dart`：待办列表、空态、筛选侧栏、智能排序、批量模式、拖拽排序、三种待办行、底部输入栏入口。
- `frontend/lib/features/todo/todo_detail_page.dart`：待办新建/编辑详情页、类型切换、时间选择、半星优先级、重复设置、删除确认。
- `frontend/lib/features/todo/todo_tag_page.dart`：tag 多选和新增 tag 弹窗。
- `frontend/lib/features/todo/todo_search_page.dart`：待办搜索、历史、清空历史确认、结果列表。
- `frontend/lib/features/recommendation/next_thing_page.dart`：下一件事状态滑杆和推荐结果页。
- `frontend/lib/features/goal_split/goal_split_page.dart`：大目标拆分三步流程和确认生成。

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
