# NJU Timenote Flutter 前端推进路线图

本文档用于指导后续多个 Flutter 前端开发 Agent 小步推进 NJU Timenote 前端实现。它不是一次性总包任务清单，而是按“可独立开发、可独立验收、可安全回退”的粒度组织路线。

每个新 Agent 开始任务前应先阅读：

1. `docs/ai-frontend-collaboration-guide.md`
2. `docs/feature-scope.md`
3. `docs/code-map.md`，若尚不存在则本路线图的 M0 必须先创建
4. `docs/frontend-backend-contract.md` 中与本任务相关的模型、接口和业务规则
5. `docs/interaction.md` 中与本任务相关的交互原文
6. `UI/nju-timenote.pen` 中对应页面结构

## 1. 推进原则

- 每轮只做一个页面、一个状态流或一个组件族，完成后交给产品经理手动测试。
- 视觉以 `UI/nju-timenote.pen` 为准，尤其是顶部蓝紫粉柔和背景、白色卡片、阴影、圆角、间距和文字层级。背景必须明确控制为只有页面顶部约四分之一高度呈现蓝紫粉柔和渐变，下面约四分之三保持纯白或接近纯白底色，不要把渐变铺满整页。
- 逻辑以 `docs/frontend-backend-contract.md` 为准，不擅自改字段、枚举、接口路径和核心业务规则。
- 初始真实状态不得伪装为已有业务数据。需要演示数据时，必须集中放在 mock/fake 数据源，并通过 repository 抽象进入 UI。
- 首发 Android 手机竖屏。平板、横屏、iOS、Web、桌面端当前不做。
- 当前本地优先，不做登录、云同步和同步队列，但代码结构要给未来后端 API 留边界。
- 每完成一个可独立验证的小功能，应格式化、静态检查、必要测试、更新文档并 Git commit。

## 2. 原型页面索引

后续 Agent 读取 Pencil 时优先按下列页面名定位：

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

## 3. 建议工程方向

若仓库仍未接入 Flutter 工程，M0 应创建最小 Flutter Android 工程，并采用接近下列结构：

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

状态管理、路由和本地存储方案由实现 Agent 根据 Flutter 工程实际情况选择，但必须满足：

- UI 不直接访问 HTTP、本地数据库或文件存储。
- model 字段与契约模型一致，尤其是 `Course`、`TodoItem`、`TodoDraft`、`TodoPatch`、`TodoFilter`、`GoalSplitDraft`。
- repository 隐藏本地数据源、mock 数据源和未来 remote 数据源差异。
- 主题、颜色、字体、圆角、阴影等进入 theme/design token，不散落在页面深处。
- 思源宋体资源和许可证文本需要随工程声明。

## 4. 里程碑

### M0 工程与协作基建

目标：让仓库具备可运行、可检查、可继续拆任务的 Flutter 前端基础。

范围：

- 创建或接入 Flutter Android 工程。
- 建立路由、主题、基础页面壳、错误/加载/空状态组件。
- 建立本地优先的数据层骨架：models、repositories、local/mock/remote source。
- 建立 `docs/code-map.md`，记录目录职责、路由位置、主题位置、数据层入口和常见任务读文件清单。
- 建立 `docs/manual-test-checklist.md`，先放工程启动、首页壳、路由跳转的基础手测项。

验收：

- App 能在 Android 模拟器或设备启动。
- 能进入空白或占位首页，不出现默认 Material 裸奔感。
- `flutter format`、`flutter analyze` 可运行；若有失败，必须说明原因。
- 代码地图能让下一个 Agent 不读全仓库也知道入口在哪里。

不做：

- 不实现完整业务页面。
- 不接真实后端。
- 不塞散落在 Widget 中的示例业务数据。

### M1 设计系统与通用页面骨架

目标：先把全 App 的视觉语言和可复用结构稳定下来，减少后续页面各写各的。

范围：

- 实现顶部状态区域下的柔和蓝紫粉背景、App header、白色卡片、按钮、底部输入栏、弹窗、侧栏、列表行等通用组件。背景组件应固定表达“顶部约 1/4 渐变、其余白底”的页面基底，后续页面不得自行改成全屏渐变。
- 实现常用交互控件：图标按钮、确认弹窗、底部浮层、右侧筛选抽屉、滚轮选择器壳、半星评分壳。
- 建立全局文本样式，统一思源宋体。
- 为 Android 手机竖屏做小屏防溢出约束。

验收：

- 使用 `01 Home Page`、`02 Week Timetable`、`04 Todos` 中的共同结构做截图对比。
- 同类卡片阴影、圆角、间距一致。
- 长标题、窄屏、键盘弹出时不明显遮挡关键操作。

不做：

- 不在此阶段实现所有页面业务逻辑。
- 不为了复刻原型而硬编码真实业务数据。

### M2 首页可用壳与主导航

目标：让用户从首页进入主要功能，形成 App 的导航骨架。

设计依据：`01 Home Page`。

范围：

- 首页布局：Header、下一节课卡片、下一件事卡片、DDL 提醒卡片、底部输入栏。
- 设置入口跳转设置页。
- 下一节课卡片跳转课表页。
- 下一件事卡片跳转待办页或推荐入口，按交互文档保持清晰。
- DDL 提醒卡片跳转待办页并带 `onlyDeadline=true` 语义。
- 快速挑选图标跳转下一件事页。
- 搜索图标跳转待办搜索页。
- 点击底部输入栏唤起创建待办浮层。

验收：

- 首页无业务数据时展示合理空态，不伪装真实下一节课或真实 DDL。
- 所有入口能路由到对应占位或已实现页面。
- 返回路径符合交互文档，无法确定的来源返回应保留来源上下文。

待产品确认：

- “下一件事卡片”点击到底跳待办列表还是下一件事推荐入口，交互文档中首页卡片与左下角快速挑选入口存在轻微分工差异。保守实现可让卡片跳待办页，快速挑选跳推荐页。

### M3 本地数据模型与 Repository 纵切

目标：在页面深入前先固定业务数据边界，避免 UI 后续返工。

范围：

- 实现契约模型：`Course`、`TodoItem`、`TodoDraft`、`TodoPatch`、`TodoFilter`、`RecommendationInput`、`TodoRecommendation`、`GoalSplitDraft`、`SemesterSettings`、`PeriodTime`。
- 实现本地 repository 接口和 fake/mock source。
- 客户端生成 ID，时间使用 ISO 8601 带时区。
- 预置标签首次使用入库：`考试`、`作业`、`讲座`、`会议`、`生活`、`学习`。
- 课程名到 `colorKey` 的稳定映射。
- 待办排序：未完成在前，组内按 `deadlineAt ?? startAt` 升序，无时间项在有时间项后。
- duration 待办结束时间过去后自动完成的领域方法或刷新钩子。

验收：

- 有单元测试覆盖模型序列化、筛选、排序、批量完成跳过 duration、课程周次筛选、课程颜色稳定映射。
- 页面层通过 repository 读写，不直接依赖具体存储。

不做：

- 不接真实远端 CRUD。
- 不做重复待办自动生成。

### M4 课表主页面

目标：实现可手测的周课表展示和删除。

设计依据：`02 Week Timetable`、`02 Week Timetable delete`。

范围：

- 课表网格，星期与节次展示。
- 按教学周筛选课程，支持 `all`、`odd`、`even`。
- 课程块跨多节连续显示。
- 跨上下午的课程切割为两个块。
- 冲突课程在同一格内左右排列。
- 长按课程弹出删除确认，确认后删除并刷新。
- 右上角加号跳转添加课表页。

验收：

- 蓝、紫、粉低饱和高明度色板符合原型方向，同名课程稳定同色。
- 表格线浅，课程块尽量填满格子并保留圆角。
- 空课表展示空态或轻提示，而不是示例课程。
- 使用构造数据手测：单节、跨节、跨上午/下午、同格冲突、不同周次。

不做：

- 点击课程进入详情当前不做。
- 节假日、调休、停课、补课自动适配不做。

### M5 添加课程流程

目标：完成手动添加课程和截图添加的前端流程边界。

设计依据：`02 Week Timetable add`、`02 Week Timetable add manual`、`02 Week Timetable add manual week`、`02 Week Timetable add manual period`、`02 Week Timetable add screenshoot`。

范围：

- 添加课表入口页：手动添加、截图添加。
- 手动表单：名称、教师、地点、备注、周次规则、起止周、星期、起止节次。
- 周次滚轮选择器：全部/单周/双周、1-25 起始周、1-25 结束周。
- 节次滚轮选择器：周一至周日、1-12 起始节、1-12 结束节。
- 前端校验：名称必填、地点必填、起止周合法、起止节合法。
- 提交后写入 repository，返回课表并刷新。
- 截图添加页先实现前端选择/确认/识别中/结果确认流程壳；真实识别服务未定时不得直接入库。

验收：

- 非法选择有明确处理：禁用提交、自动修正或提示，但行为需在代码注释或手测文档中说明。
- 创建课程后能在课表看到新课程。
- 截图识别结果写入前必须有用户确认页或确认状态。

待产品确认：

- 截图识别服务未定时，MCP 阶段是否允许用“待接入识别服务”的空结果确认页，还是需要 mock 一份识别结果仅用于演示。

### M6 待办列表、筛选与完成

目标：实现待办列表主工作流，覆盖三种待办展示和筛选侧栏。

设计依据：`04 Todos`、`04 Todos Filter Sidebar`、`04 Todos Filter Date Picker`。

范围：

- 待办列表可上下滑动。
- 三种展示：duration、deadline、normal。
- 已完成项置底、弱化、标题划线、不显示序号但保持对齐。
- normal 和 deadline 显示完成按钮；duration 结束前不显示或不可手动完成。
- 右侧筛选侧栏：日期互斥、种类多选、完成情况多选、tag 多选。
- 点击侧栏外关闭并刷新筛选结果。
- 底部下一件事、输入框、搜索结构与首页一致。

验收：

- 筛选参数能映射到 `TodoFilter`。
- 搜索、创建、推荐入口跳转可用。
- 无待办、筛选无结果、全部完成时有合理状态。
- duration 到期自动完成逻辑在列表刷新时生效。

### M7 待办详情、编辑、删除、tag 与重复设置

目标：完成单条待办的创建、编辑和删除闭环。

设计依据：`04 Todos Detail Normal`、`04 Todos Detail Duration`、`04 Todos Detail DDL`、`04 Todos Detail Time Picker`、`04 Todos Detail Delete Confirm`、`04 Todos Detail Repeat Popup`、`04 Todos Detail Tag Add Empty`、`04 Todos Detail Tag Add Filled`、`04 Todos Detail Create`。

范围：

- 标题、内容、地点可编辑。
- kind 三选一：duration、deadline、normal。
- 根据 kind 展示 start/end 或 DDL 时间选择。
- 半星重要程度输入。
- tag 选择、多选、新增 tag，新增后进入本地 tag 库。
- repeatRule 弹窗：once、daily、weekly，仅保存不生成重复实例。
- 详情页删除待办，二次确认后返回。
- 新建待办详情页复用详情结构，字段为空白。

验收：

- kind 切换时字段清理符合契约：normal 清空时间，deadline 只保留 deadlineAt，duration 必须有 startAt/endAt。
- duration 结束前不能手动完成，详情页不提供手动完成入口。
- 创建或更新待办携带新 tag 时，tag 自动入库。
- 表单失败不丢用户已输入内容。

### M8 批量操作

目标：实现待办批量删除与批量完成。

设计依据：`04 Todos Batch`、`04 Todos Batch Cancel All`、`04 Todos Batch Delete Confirm`、`04 Todos Batch Complete Confirm`。

范围：

- 进入批量模式。
- 全选/取消全选。
- 点选待办行，右侧圆圈显示勾选态。
- 底部浮栏：删除、完成。
- 删除二次确认。
- 批量完成二次确认，并跳过 duration 类型。
- 操作成功后立即刷新列表。

验收：

- 未选择任何项时操作按钮禁用或提示。
- 批量完成后 duration 待办仍保持原状态。
- 已完成项再次批量完成不产生异常。

### M9 一句话创建与大目标拆分

目标：实现创建待办浮层、临时智能创建策略和大目标手动拆分。

设计依据：`04 Todos Create Empty`、`04 Todos Create Filled`、`04 Todos Goal Split Setup`、`04 Todos Goal Split Breakdown`、`04 Todos Goal Split Review`、`04 Todos Goal Split Review Confirm`。

范围：

- 点击底部输入栏唤起创建浮层。
- 未输入时显示提示，输入后提交按钮亮起。
- 一句话创建临时行为：整句话作为普通待办标题创建，但必须封装在智能解析 service/repository 后。
- 手动创建跳转新建待办详情。
- 大目标拆分三步：设定大目标、拆分小目标、确认生成。
- 从创建浮层带入大目标名称，步骤间返回保留草稿。
- 确认生成时按 `GoalSplitDraft` 规则批量创建 deadline 待办。

验收：

- 最终 DDL 不早于今天。
- 小目标日期不早于今天、不晚于最终 DDL。
- 至少一个小目标才能预览拆分。
- 确认生成前有二次确认，生成后返回待办列表刷新。
- 任意子目标创建失败时，前端表现为全部失败，不出现部分成功的误导。

不做：

- 不接真实 AI 解析。
- 不做 AI 自动拆分。

### M10 待办搜索

目标：实现完整搜索体验。

设计依据：`04 Todos Search`、`04 Todos Search Results`。

范围：

- 进入页自动聚焦搜索框并唤起键盘。
- 搜索历史：点击填入并执行、清空历史二次确认。
- 输入后清空按钮亮起。
- 点击搜索按钮执行大小写不敏感搜索。
- 搜索范围：title、content、location、tags。
- 结果点击进入详情。

验收：

- 空关键词不执行无意义搜索或给出轻提示。
- 无结果展示空状态。
- 历史记录不重复堆叠同一关键词。
- 从首页或待办页进入后，返回来时页面。

### M11 下一件事推荐

目标：完成当前阶段的非 AI 推荐体验。

设计依据：`04 Todos Next`、`04 Todos Next Recommend`、`04 Todos Next Recommend Empty`。

范围：

- 状态输入页：心情、启动意愿、焦虑三个 1-100 滑杆。
- 推荐按钮跳转推荐结果页。
- 临时推荐策略：从已有待办中 roll 出“不得不做”和“适合当前状态”的候选，tag 可参与分组或加权。
- “其他可以做的事”从前端本地建议中 roll。
- 推荐条目点击进入待办详情。
- 其他建议右侧加号可添加到待办，添加后可取消。
- 换一批重新推荐。
- 无待办时展示合理推荐空态和本地建议。

验收：

- 三个滑杆取值始终在 1-100。
- 推荐结果符合 `TodoRecommendation` 数据结构。
- 无待办时不崩溃，不展示伪造的用户待办。
- 返回来时页面，支持从首页或待办页进入。

不做：

- 不接真实 AI 推荐接口。

### M12 设置页与最小设置能力

目标：给课表周数和未来设置能力留入口。

设计依据：`03 Settings`。

范围：

- 设置页视觉结构：课表与作息、数据与分享。
- 学期周数或学期开学日的最小可用设置，按实际原型缺失程度保守实现。
- 展示当前节次时间配置，完整编辑可先标注为未来能力。
- 数据备份、导出入口可做占位，不伪装已完成。

验收：

- 首页设置入口可进入并返回。
- 设置值进入 repository/config 层，不写死在课表 Widget 内。
- 未实现能力有明确占位状态，不影响核心功能。

待产品确认：

- 原型设置页已有“课表与作息”“数据与分享”结构，但学期周数编辑细节不充分。MCP 阶段建议先做最小学期开学日/周数设置，其余作为占位。

## 5. 贯穿式验收清单

每个功能切片完成前都应检查：

- 是否读取了对应 Pencil 页面结构。
- 是否遵守 `docs/frontend-backend-contract.md` 的模型、枚举和业务规则。
- 是否更新 `docs/code-map.md`。
- 是否需要更新 `docs/manual-test-checklist.md`。
- 是否有空态、加载态、错误态、禁用态。
- 是否避免在 UI Widget 中散落 mock 数据。
- 是否处理 Android 小屏文字溢出、键盘遮挡和安全区域。
- 是否运行格式化、静态检查和必要测试。
- 是否截图对比原型，重点看布局、字号、颜色、圆角、阴影、间距和层级。
- 是否完成独立 Git commit。

## 6. 当前明确不做

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

## 7. 建议提交顺序

推荐按下列顺序推进，除非产品经理明确调整：

1. M0 工程与协作基建
2. M1 设计系统与通用页面骨架
3. M3 本地数据模型与 Repository 纵切
4. M2 首页可用壳与主导航
5. M4 课表主页面
6. M5 添加课程流程
7. M6 待办列表、筛选与完成
8. M7 待办详情、编辑、删除、tag 与重复设置
9. M8 批量操作
10. M9 一句话创建与大目标拆分
11. M10 待办搜索
12. M11 下一件事推荐
13. M12 设置页与最小设置能力

说明：M3 排在 M2 之后或之前都可行。若实现 Agent 先做首页壳，必须只做路由和空态，不要把业务数据临时硬编码进首页。

## 8. 待确认问题汇总

- 首页“下一件事”卡片最终跳待办列表还是下一件事推荐入口。
- 截图添加课程在识别服务未定时，是只做空流程，还是允许使用集中 mock 识别结果演示确认页。
- 设置页 MCP 阶段的最小学期设置字段：只做学期开学日，还是同时做总周数。
- duration 待办到期自动完成的触发时机：进入列表刷新时触发、App 启动时触发，还是两者都触发。
