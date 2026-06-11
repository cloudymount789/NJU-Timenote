# NJU Timenote Flutter 前端推进路线图

本文档用于指导后续 Flutter 前端开发 Agent 推进 NJU Timenote。任务粒度控制为 4 个大任务，每个任务应尽量一次完成一个可手测闭环。完成任务后，开发 Agent 应把对应 checklist 从 `- [ ]` 改为 `- [x]`，并更新 `docs/code-map.md`、`docs/manual-test-checklist.md` 等相关文档。

每个新 Agent 开始任务前应先阅读：

1. `docs/ai-frontend-collaboration-guide.md`
2. `docs/feature-scope.md`
3. `docs/code-map.md`，若尚不存在则先在任务 1 中创建
4. `docs/frontend-backend-contract.md` 中与本任务相关的模型、接口和业务规则
5. `docs/interaction.md` 中与本任务相关的交互原文
6. `UI/nju-timenote.pen` 中对应页面结构

## 1. 总原则

- 只做 Flutter 前端，不擅自修改 `docs/frontend-backend-contract.md`。
- 首发 Android 手机竖屏；平板、横屏、iOS、Web、桌面端当前不做。
- 当前本地优先，不做登录、云同步和同步队列，但必须给未来后端 API 留 repository / source 边界。
- 真实初始状态不得伪装为已有业务数据；如需演示数据，必须集中在 mock/fake 数据源，不得散落在 UI Widget 中。
- 视觉以 `UI/nju-timenote.pen` 为准。背景必须明确控制为只有页面顶部约四分之一高度呈现蓝紫粉柔和渐变，下面约四分之三保持纯白或接近纯白底色，不要把渐变铺满整页。
- 每个任务完成后应运行可用的格式化、静态检查和必要测试，截图对比原型，完成 Git commit。

## 2. 原型页面索引

| 功能 | Pencil 页面/状态 |
|---|---|
| 首页 | `01 Home Page` |
| 设置 | `03 Settings` |
| 课表 | `02 Week Timetable`、`02 Week Timetable delete` |
| 添加课表 | `02 Week Timetable add` |
| 手动添加课程 | `02 Week Timetable add manual`、`02 Week Timetable add manual week`、`02 Week Timetable add manual period` |
| 截图添加课程 | `02 Week Timetable add screenshoot` |
| 待办列表 | `04 Todos` |
| 待办筛选 | `04 Todos Filter Sidebar`、`04 Todos Filter Date Picker` |
| 待办批量 | `04 Todos Batch`、`04 Todos Batch Cancel All`、`04 Todos Batch Delete Confirm`、`04 Todos Batch Complete Confirm` |
| 待办详情 | `04 Todos Detail Normal`、`04 Todos Detail Duration`、`04 Todos Detail DDL` |
| 详情弹窗 | `04 Todos Detail Time Picker`、`04 Todos Detail Delete Confirm`、`04 Todos Detail Repeat Popup` |
| tag 选择/新增 | `04 Todos Detail Tag Add Empty`、`04 Todos Detail Tag Add Filled` |
| 下一件事 | `04 Todos Next` |
| 推荐结果 | `04 Todos Next Recommend`、`04 Todos Next Recommend Empty` |
| 创建待办浮层 | `04 Todos Create Empty`、`04 Todos Create Filled` |
| 新建待办详情 | `04 Todos Detail Create` |
| 待办搜索 | `04 Todos Search`、`04 Todos Search Results` |
| 大目标拆分 | `04 Todos Goal Split Setup`、`04 Todos Goal Split Breakdown`、`04 Todos Goal Split Review`、`04 Todos Goal Split Review Confirm` |

## 3. 建议工程结构

若仓库仍未接入 Flutter 工程，任务 1 应创建最小 Flutter Android 工程，并采用接近下列结构：

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme/
  core/
    errors/
    time/
    widgets/
    utils/
  data/
    models/
    repositories/
    sources/
      local/
      mock/
      remote/
  features/
    home/
    schedule/
    settings/
    todo/
    recommendation/
    goal_split/
```

状态管理、路由和本地存储方案可由实现 Agent 根据工程实际选择，但必须满足：

- UI 不直接访问 HTTP、本地数据库或文件存储。
- model 字段与契约模型一致，尤其是 `Course`、`TodoItem`、`TodoDraft`、`TodoPatch`、`TodoFilter`、`GoalSplitDraft`。
- repository 隐藏本地数据源、mock 数据源和未来 remote 数据源差异。
- 主题、颜色、字体、圆角、阴影等进入 theme/design token，不散落在页面深处。
- 思源宋体资源和许可证文本需要随工程声明。

## 4. 四个推进任务

### 任务 1：工程基建、设计系统、首页与主导航

目标：让 App 能跑起来，建立统一视觉和数据边界，并完成首页到各核心模块的导航骨架。

设计依据：`01 Home Page`、`03 Settings`，以及各页面共同的 Header、顶部背景、白色卡片、底部输入栏、弹窗样式。

要做：

- [ ] 创建或接入 Flutter Android 工程，确保 App 能在 Android 模拟器或真机启动。
- [ ] 建立路由系统，覆盖首页、设置、课表、添加课表、待办、待办详情、待办搜索、下一件事、大目标拆分等页面入口。
- [ ] 建立 `docs/code-map.md`，记录入口文件、路由、主题、数据层、页面目录、常见任务应读文件。
- [ ] 建立 `docs/manual-test-checklist.md`，先记录启动、首页、导航、基础空态的手测项。
- [ ] 建立 theme/design token：颜色、字号、圆角、阴影、间距、思源宋体。
- [ ] 实现统一页面基底：顶部约 1/4 蓝紫粉柔和渐变，其余白底；不得做全屏渐变。
- [ ] 实现通用组件：App header、图标按钮、白色卡片、底部输入栏、确认弹窗、底部浮层、右侧侧栏、滚轮选择器壳、空态、加载态、错误态、禁用态。
- [ ] 建立契约模型和 repository 骨架：课程、待办、标签、设置、推荐、大目标拆分。
- [ ] 建立本地/fake/mock source 边界，确保 UI 不直接访问存储或 HTTP。
- [ ] 实现首页布局：Header、下一节课卡片、下一件事卡片、DDL 提醒卡片、底部输入栏。
- [ ] 首页设置入口跳转设置页。
- [ ] 首页下一节课卡片跳转课表页。
- [ ] 首页下一件事卡片跳转待办页；左下角快速挑选图标跳转下一件事页。
- [ ] 首页 DDL 提醒卡片跳转待办页，并带 `onlyDeadline=true` 语义。
- [ ] 首页搜索图标跳转待办搜索页。
- [ ] 首页底部输入栏唤起创建待办浮层。
- [ ] 设置页先完成最小可用入口：课表与作息、数据与分享分区；未实现项明确占位，不伪装已完成。
- [ ] 完成格式化、静态检查、必要测试、截图对比和 Git commit。

验收重点：

- [ ] App 可以启动并进入首页。
- [ ] 首页无真实业务数据时展示合理空态，不硬编码示例课程或示例待办。
- [ ] 所有主入口能跳到对应页面或占位页，并能返回。
- [ ] 视觉不是默认 Material 裸奔；顶部渐变只占约四分之一，下面保持白底。
- [ ] `docs/code-map.md` 和 `docs/manual-test-checklist.md` 已建立。

待产品确认：

- [ ] 首页“下一件事”卡片最终是否仍保持跳待办页；当前保守按交互文档处理为卡片跳待办页、快速挑选跳下一件事页。
- [ ] 设置页 MCP 阶段的最小学期设置字段：只做学期开学日，还是同时做总周数。

### 任务 2：课表完整闭环

目标：完成课表查看、手动添加、截图添加流程壳、删除和课表规则边界，让课程模块可以独立手测。

设计依据：`02 Week Timetable`、`02 Week Timetable delete`、`02 Week Timetable add`、`02 Week Timetable add manual`、`02 Week Timetable add manual week`、`02 Week Timetable add manual period`、`02 Week Timetable add screenshoot`。

要做：

- [ ] 实现 `Course` model 序列化/反序列化，与契约字段、枚举、约束一致。
- [ ] 实现课程 repository：查询指定教学周课程、创建课程、删除课程。
- [ ] 实现课程名到 `colorKey` 的稳定映射；同名课程在不同周保持同色。
- [ ] 实现课程周次筛选：`all`、`odd`、`even`，周次范围 1-25。
- [ ] 实现课表页 Header、返回首页、右上角添加入口。
- [ ] 实现课表网格：星期、节次、浅色表格线、课程块。
- [ ] 实现课程块视觉：蓝/紫/粉低饱和高明度色板、圆角、尽量占满格子、不明显留缝。
- [ ] 实现跨多节课程连续显示。
- [ ] 实现跨上午/下午课程切割成两个块。
- [ ] 实现冲突课程在同一格内左右排列。
- [ ] 实现空课表状态，不展示伪造课程。
- [ ] 实现长按课程弹出删除确认；确认删除后刷新课表，取消后返回。
- [ ] 实现添加课表入口页：手动添加课程、截图添加课程两个选项。
- [ ] 实现手动添加课程表单：课程名称、任课教师、地点、备注。
- [ ] 实现周次选择弹窗：全部/单周/双周、起始周 1-25、结束周 1-25，默认全部-第 1 周-第 25 周。
- [ ] 实现节次选择弹窗：周一至周日、起始节 1-12、结束节 1-12，默认周一第 1-1 节。
- [ ] 实现前端校验：课程名称必填、地点必填、结束周不得小于起始周、结束节不得小于起始节。
- [ ] 手动添加成功后写入 repository，返回课表页并刷新显示。
- [ ] 实现截图添加课程页面流程壳：选择/导入截图、确认、识别中、结果确认或服务未接入提示。
- [ ] 截图识别结果写入前必须让用户确认，不得识别后直接入库。
- [ ] 补充课程模块单元测试或逻辑测试：周次筛选、颜色稳定、冲突布局、跨节/切割规则。
- [ ] 更新 `docs/code-map.md` 和 `docs/manual-test-checklist.md`。
- [ ] 完成格式化、静态检查、必要测试、截图对比和 Git commit。

验收重点：

- [ ] 使用构造数据能手测单节、跨节、跨上午/下午、冲突、单双周课程。
- [ ] 新增课程后课表立即刷新。
- [ ] 删除课程有二次确认且删除后不可见。
- [ ] 课表主色、线条、卡片阴影、圆角、间距贴近原型。

待产品确认：

- [ ] 截图识别服务未定时，是只做“待接入识别服务”的空流程，还是允许集中 mock 一份识别结果演示确认页。

### 任务 3：待办核心闭环

目标：完成待办列表、筛选、详情、新建、编辑、删除、tag、重复设置和批量操作，让待办作为核心模块可长期使用。

设计依据：`04 Todos`、`04 Todos Filter Sidebar`、`04 Todos Filter Date Picker`、`04 Todos Batch`、`04 Todos Batch Cancel All`、`04 Todos Batch Delete Confirm`、`04 Todos Batch Complete Confirm`、`04 Todos Detail Normal`、`04 Todos Detail Duration`、`04 Todos Detail DDL`、`04 Todos Detail Time Picker`、`04 Todos Detail Delete Confirm`、`04 Todos Detail Repeat Popup`、`04 Todos Detail Tag Add Empty`、`04 Todos Detail Tag Add Filled`、`04 Todos Detail Create`。

要做：

- [ ] 实现 `TodoItem`、`TodoDraft`、`TodoPatch`、`TodoFilter` model，与契约字段、枚举、PATCH 语义一致。
- [ ] 实现 todo repository：查询、筛选、创建、更新、删除、完成、批量删除、批量完成、搜索基础能力。
- [ ] 实现预置 tag 首次入库：考试、作业、讲座、会议、生活、学习。
- [ ] 创建或更新待办时，携带的新 tag 自动加入本地 tag 库。
- [ ] 实现待办排序：未完成在前，已完成置底；组内按 `deadlineAt ?? startAt` 升序；无时间项在有时间项后。
- [ ] 实现 duration 待办结束时间过去后自动完成；结束时间前不能被手动完成。
- [ ] 实现待办列表可上下滑动。
- [ ] 实现三种待办列表行：有持续时间、有 DDL、普通待办。
- [ ] 有持续时间待办展示持续时间，不展示完成按钮或禁用手动完成。
- [ ] 有 DDL 待办展示完成按钮和 `DDL: M.DD HH:mm` 文案。
- [ ] 普通待办展示完成按钮。
- [ ] 已完成待办标题划线并弱化，不显示序号，但文字与未完成项对齐。
- [ ] 实现列表页返回首页、右上角筛选、右上角批量、底部下一件事/输入框/搜索结构。
- [ ] 实现筛选侧栏：日期全部/具体时间互斥，种类、完成情况、tag 多选。
- [ ] 实现日期选择弹窗，确认后更新筛选日期。
- [ ] 点击筛选侧栏外关闭并刷新结果。
- [ ] 实现待办详情页字段编辑：标题、内容、地点。
- [ ] 实现待办种类单选：duration、deadline、normal，互斥选中。
- [ ] kind 切换时按契约清理字段：normal 清空时间，deadline 只保留 deadlineAt，duration 必须 startAt/endAt。
- [ ] 实现时间滚轮选择：duration 起止时间、deadline DDL 时间。
- [ ] 实现半星重要程度输入，范围 0.0-5.0。
- [ ] 实现 tag 选择页：预置 tag 展示、多选、高亮、返回后更新详情页。
- [ ] 实现新增 tag 弹窗：输入为空时确定按钮禁用，确认后加入 tag 库。
- [ ] 实现重复设置弹窗：仅一次/每天/每周；MCP 阶段只保存 `repeatRule`，不自动生成重复实例。
- [ ] 实现详情页删除待办，二次确认后删除并返回。
- [ ] 实现新建待办详情页，字段为空白，可保存为普通/DDL/duration 待办。
- [ ] 实现批量模式：进入/退出、全选/取消全选、逐项勾选。
- [ ] 实现批量删除二次确认，确认后立即刷新列表。
- [ ] 实现批量完成二次确认，必须跳过 duration 类型，确认后立即刷新列表。
- [ ] 实现待办空态、筛选无结果、删除失败/保存失败错误态。
- [ ] 补充待办核心测试：排序、筛选、duration 自动完成、批量完成跳过 duration、tag 自动入库、kind 字段清理。
- [ ] 更新 `docs/code-map.md` 和 `docs/manual-test-checklist.md`。
- [ ] 完成格式化、静态检查、必要测试、截图对比和 Git commit。

验收重点：

- [ ] 三种待办展示、完成限制和已完成置底符合规约。
- [ ] 筛选、详情编辑、新建、删除、批量操作都能真实改变本地数据。
- [ ] 表单失败不丢用户已输入内容。
- [ ] 没有待办或筛选无结果时不展示假数据。

待产品确认：

- [ ] duration 待办到期自动完成的触发时机：进入列表刷新时触发、App 启动时触发，还是两者都触发。

### 任务 4：创建浮层、搜索、下一件事推荐与大目标拆分

目标：完成待办周边高频入口和智能能力的当前阶段替代实现，让首页底部输入、搜索、推荐、大目标拆分形成可用闭环。

设计依据：`04 Todos Create Empty`、`04 Todos Create Filled`、`04 Todos Search`、`04 Todos Search Results`、`04 Todos Next`、`04 Todos Next Recommend`、`04 Todos Next Recommend Empty`、`04 Todos Goal Split Setup`、`04 Todos Goal Split Breakdown`、`04 Todos Goal Split Review`、`04 Todos Goal Split Review Confirm`。

要做：

- [ ] 实现点击首页/待办页底部输入栏唤起创建待办浮层。
- [ ] 创建浮层未输入时显示提示：“用一句话，记录待办的内容，时间，地点，重要程度吧~”。
- [ ] 创建浮层输入内容后，右下角向上箭头亮起。
- [ ] 实现一句话创建临时行为：把整句话作为普通待办标题创建。
- [ ] 一句话创建必须封装在智能解析 service/repository 后，方便未来替换真实 AI。
- [ ] 创建成功后返回待办页并刷新。
- [ ] 创建浮层“手动创建待办”跳转新建待办详情页。
- [ ] 创建浮层“大目标拆分”入口跳转大目标拆分步骤 1；若浮层已有输入，带入大目标名称。
- [ ] 实现待办搜索页进入后自动聚焦搜索框并唤起键盘。
- [ ] 实现搜索历史：点击历史 tag 填入关键词并执行搜索。
- [ ] 实现清空历史记录二次确认。
- [ ] 实现搜索框清空按钮，输入后亮起。
- [ ] 实现大小写不敏感搜索，范围为 title/content/location/tags。
- [ ] 实现搜索无结果空态。
- [ ] 搜索结果点击进入待办详情。
- [ ] 从首页或待办页进入搜索后，返回来时页面。
- [ ] 实现下一件事状态输入页：心情、启动意愿、焦虑三个 1-100 滑杆。
- [ ] 点击推荐待办后进入推荐结果页。
- [ ] 实现当前阶段临时推荐策略：从已有待办中 roll 出“不得不做”和“适合当前状态”的候选，tag 可参与分组或加权。
- [ ] “其他可以做的事”从前端本地建议中 roll。
- [ ] 推荐结果符合 `TodoRecommendation` 结构。
- [ ] 推荐条目点击进入待办详情。
- [ ] 其他建议右侧加号可添加到待办，添加后可取消添加。
- [ ] 换一批按钮重新推荐。
- [ ] 用户没有待办时展示合理空态和本地建议，不展示伪造的用户待办。
- [ ] 从首页或待办页进入下一件事后，返回来时页面。
- [ ] 实现大目标拆分步骤 1：大目标名称、最终截止 DDL、备注；必填未完成时下一步置灰。
- [ ] 前端校验最终 DDL 不应早于今天。
- [ ] 实现大目标拆分步骤 2：展示摘要、添加小目标、填写小目标名称、选择计划完成日期、删除小目标。
- [ ] 前端校验小目标日期不早于今天、不晚于最终 DDL。
- [ ] 至少 1 条小目标后才能进入预览。
- [ ] 实现大目标拆分步骤 3：按计划完成日期分组展示时间线。
- [ ] 点击确认生成前弹出二次确认。
- [ ] 确认后为每条小目标创建 deadline 待办，DDL 为对应计划日期 23:59，默认优先级 4，默认 tag 为学习。
- [ ] 任意一条小目标创建失败时，前端表现为全部失败，不出现部分成功的误导。
- [ ] 步骤间返回保留草稿，从步骤 1 返回创建浮层也保留已填内容。
- [ ] 补充测试：一句话创建、搜索匹配、推荐无待办、大目标日期校验、批量生成规则。
- [ ] 更新 `docs/code-map.md` 和 `docs/manual-test-checklist.md`。
- [ ] 完成格式化、静态检查、必要测试、截图对比和 Git commit。

验收重点：

- [ ] 首页/待办页底部输入、搜索、下一件事、大目标拆分都能形成闭环。
- [ ] 当前阶段不接真实 AI，但 AI 相关入口和替换边界明确。
- [ ] 搜索、推荐、大目标拆分都不使用散落在 UI 中的假数据。
- [ ] 无待办、无搜索结果、生成失败等边界状态可见且稳定。

## 5. 当前明确不做

- 登录、用户体系。
- 云端同步、多设备同步、同步队列。
- 真实 AI 一句话解析。
- 真实 AI 下一件事推荐。
- AI 自动大目标拆分。
- 真实截图识别服务接入。
- 教务系统导入。
- 节假日、调休、停课、补课自动处理。
- iOS、Web、桌面端、平板、横屏适配。
- 暗色模式实际切换。
- App logo、启动页和完整图标体系。

## 6. 每个任务完成前必须检查

- [ ] 已读取本任务对应 Pencil 页面结构。
- [ ] 已遵守 `docs/frontend-backend-contract.md` 的模型、枚举和业务规则。
- [ ] 已避免在 UI Widget 中散落 mock 数据。
- [ ] 已覆盖空态、加载态、错误态、禁用态。
- [ ] 已处理 Android 小屏文字溢出、键盘遮挡和安全区域。
- [ ] 已更新 `docs/code-map.md`。
- [ ] 已更新 `docs/manual-test-checklist.md`。
- [ ] 已运行格式化、静态检查和必要测试；若不能运行，已说明原因。
- [ ] 已截图对比原型，重点看布局、字号、颜色、圆角、阴影、间距和层级。
- [ ] 已完成独立 Git commit。
