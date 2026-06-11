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
- `frontend/lib/core/widgets/app_bottom_input_bar.dart`：快速挑选、一句话输入和搜索底部栏。
- `frontend/lib/core/widgets/create_todo_sheet.dart`：任务 1 的创建待办底部浮层壳。
- `frontend/lib/core/widgets/app_dialogs.dart`：确认弹窗和滚轮选择器壳。
- `frontend/lib/core/widgets/right_sidebar_shell.dart`：右侧侧栏壳。
- `frontend/lib/core/widgets/state_views.dart`：空态、加载态、错误态、禁用态。
- `frontend/lib/core/widgets/placeholder_page.dart`：后续任务用的占位页面壳。

## 数据边界

- `frontend/lib/data/models/`：按接口契约形状建立的课程、待办、设置、推荐、大目标拆分模型。
- `frontend/lib/data/repositories/`：repository 接口和本地 repository 工厂。
- `frontend/lib/data/sources/local/`：本地 source 骨架；任务 1 默认返回空状态。
- `frontend/lib/data/sources/mock/`：mock 边界占位；默认不启用 mock 数据。
- `frontend/lib/data/sources/remote/`：未来后端边界占位；UI 不得直接调用。

## 功能页面

- `frontend/lib/features/home/home_page.dart`：任务 1 首页和主导航。
- `frontend/lib/features/settings/settings_page.dart`：最小设置入口，包含课表与作息、数据与分享分区。
- `frontend/lib/features/schedule/`：任务 2 的课表与添加课表占位路由。
- `frontend/lib/features/todo/`：任务 3/4 的待办列表、详情、搜索占位路由。
- `frontend/lib/features/recommendation/`：任务 4 的下一件事入口。
- `frontend/lib/features/goal_split/`：任务 4 的大目标拆分入口。

## 常见修改入口

- 新增或修改路由：先看 `frontend/lib/app/router.dart`，再看目标 feature 页面。
- 调整全局颜色、阴影、圆角、字号或字体：改 `frontend/lib/app/theme/` 和对应通用组件。
- 新增业务数据访问：先定义或扩展 `frontend/lib/data/repositories/`，再通过 source 实现，并在 `RepositoryFactory` 注入。
- 按原型新增页面：优先复用 `GradientPageScaffold`、`AppHeader`、`AppCard` 和状态视图。
- 运行检查：进入 `frontend/` 后执行 `dart format lib test`、`flutter analyze`、`flutter test`。

## 边界

- 不要擅自修改 `docs/frontend-backend-contract.md`。
- UI Widget 不直接访问 HTTP、数据库、文件或平台存储。
- 不要在 UI Widget 中散落假业务数据。需要演示或测试数据时，只能集中放在 mock/fake source。
