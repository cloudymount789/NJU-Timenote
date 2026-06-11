# NJU Timenote 前端 API 契约

本文档是 NJU Timenote 前后端之间的接口契约。前端（无论是现有 Flutter 版本还是重写版本）应以此文档为唯一真相来源，对接后端 API。

---

## 1. 架构约定

### 1.1 本地优先（Local-First）

- 课程、待办、标签、设置等**核心用户数据默认保存在设备本地**
- 后端是**可选辅助服务**，不可用时 App 核心功能必须仍可使用
- 后端**不存储**用户的课程、待办、标签、设置数据（至少第一阶段如此）
- 任何需要发送数据到后端的功能，**必须先告知用户**发送了什么、用来做什么

### 1.2 数据 ID 策略

所有实体 ID 由**客户端生成**，格式为 `<类型前缀>-<UUID v4>`：

| 实体 | ID 格式 |
|------|---------|
| 课程 | `course-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| 待办 | `todo-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |

后端使用客户端 ID 作为主键，不另外分配服务端 ID。这确保离线创建的数据在联网后不会发生 ID 冲突。

### 1.3 通用约定

| 项 | 约定 |
|----|------|
| Base URL | `/api/v1` |
| Content-Type | `application/json` |
| 时间戳 | ISO 8601 带时区，如 `2026-06-19T23:59:00+08:00` |
| 日期（纯日期） | `YYYY-MM-DD`，如 `2026-06-19` |
| 时间（纯时间） | `HH:mm`，24 小时制，如 `14:00` |
| 枚举值 | 全小写字符串，见各字段说明 |

### 1.4 错误格式

所有非 2xx 响应统一使用以下结构：

```json
{
  "error": {
    "code": "validation_error",
    "message": "具体错误描述"
  }
}
```

| HTTP 状态码 | 场景 |
|------------|------|
| `200` | 查询或修改成功 |
| `201` | 创建成功 |
| `204` | 删除成功，无响应体 |
| `400` | 请求格式或参数错误 |
| `404` | 资源不存在 |
| `409` | 唯一性冲突或状态冲突 |
| `422` | 业务字段校验失败 |
| `500` | 服务端未处理错误 |

---

## 2. 数据模型

### 2.1 Course（课程）

```json
{
  "id": "course-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "name": "数据结构",
  "teacher": "王老师",
  "location": "机房A",
  "note": "",
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

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `id` | string | 是 | 客户端生成 |
| `name` | string | 是 | 不能为空 |
| `teacher` | string | 否 | 默认为 `""` |
| `location` | string | 是 | 不能为空 |
| `note` | string | 否 | 默认为 `""` |
| `dayOfWeek` | integer | 是 | 1-7（周一至周日） |
| `startPeriod` | integer | 是 | 1-12，≤ `endPeriod` |
| `endPeriod` | integer | 是 | 1-12，≥ `startPeriod` |
| `weekRule` | string | 是 | `"all"` / `"odd"` / `"even"` |
| `startWeek` | integer | 是 | 1-25，≤ `endWeek` |
| `endWeek` | integer | 是 | 1-25，≥ `startWeek` |
| `colorKey` | string | 是 | 服务端/客户端根据课程名稳定生成 |
| `source` | string | 是 | `"manual"` / `"screenshot"` / `"sample"` |
| `createdAt` | datetime | 是 | 创建时间 |
| `updatedAt` | datetime | 是 | 最近修改时间 |

`colorKey` 建议值：`"blue"` / `"purple"` / `"pink"` / `"indigo"`，根据课程名称哈希稳定选择，保证同一门课始终同色。

### 2.2 TodoItem（待办）

```json
{
  "id": "todo-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
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

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `id` | string | 是 | 客户端生成 |
| `title` | string | 是 | 不能为空 |
| `content` | string | 否 | 默认为 `""` |
| `location` | string | 否 | 默认为 `""` |
| `kind` | string | 是 | `"duration"` / `"deadline"` / `"normal"` |
| `startAt` | datetime \| null | 条件 | `kind=duration` 时必填 |
| `endAt` | datetime \| null | 条件 | `kind=duration` 时必填，且 > `startAt` |
| `deadlineAt` | datetime \| null | 条件 | `kind=deadline` 时必填 |
| `priority` | number | 是 | 0.0-5.0，支持半星（0.5 步进） |
| `tags` | string[] | 是 | 标签名称数组 |
| `repeatRule` | string | 是 | `"once"` / `"daily"` / `"weekly"` |
| `status` | string | 是 | `"open"` / `"done"` |
| `createdAt` | datetime | 是 | 创建时间 |
| `updatedAt` | datetime | 是 | 最近修改时间 |

三种 `kind` 的时间字段规则：

| kind | startAt | endAt | deadlineAt |
|------|---------|-------|------------|
| `duration` | **必填** | **必填**（且 > startAt） | `null` |
| `deadline` | `null` | `null` | **必填** |
| `normal` | `null` | `null` | `null` |

### 2.3 TodoDraft（创建待办的请求体）

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

除 `id`、`status`、`createdAt`、`updatedAt` 外，其余字段与 TodoItem 相同。所有字段均可选（有默认值）：`content`/`location`/`note` 默认为空字符串，`kind` 默认 `"normal"`，`priority` 默认 `3`，`tags` 默认空数组，`repeatRule` 默认 `"once"`。

### 2.4 TodoPatch（更新待办的请求体）

```json
{
  "title": "修改后的标题",
  "kind": "normal",
  "startAt": null,
  "endAt": null,
  "deadlineAt": null,
  "priority": 4
}
```

**所有字段可选。** 核心规则：

- **字段省略**：该字段保持原值不变
- **字段显式传 `null`**：清空该字段

示例：把 `duration` 类型待办改为 `normal` 时，必须显式将 `startAt`、`endAt` 设为 `null`：

```json
{ "kind": "normal", "startAt": null, "endAt": null, "deadlineAt": null }
```

### 2.5 TodoFilter（筛选参数）

所有参数通过 **GET Query String** 传递，均为可选：

| 参数 | 格式 | 示例 | 说明 |
|------|------|------|------|
| `date` | `YYYY-MM-DD` | `?date=2026-06-19` | 匹配 `deadlineAt ?? startAt` 所在日期 |
| `kind` | 逗号分隔 | `?kind=duration,deadline` | 多选 |
| `status` | 逗号分隔 | `?status=open` | 多选 |
| `tag` | 逗号分隔 | `?tag=作业,考试` | **任意匹配**（OR 逻辑） |
| `onlyDeadline` | boolean | `?onlyDeadline=true` | 只返回有截止时间的 |

### 2.6 SearchQuery（搜索参数）

```
GET /api/v1/todos/search?q=数据结构
```

搜索范围：`title`、`content`、`location`、`tags`。大小写不敏感。结果按待办默认排序返回。

### 2.7 RecommendationInput（推荐请求体）

```json
{
  "mood": 52,
  "willingness": 68,
  "anxiety": 35
}
```

三个值范围均为 **1-100**（整数）。

### 2.8 TodoRecommendation（推荐响应）

```json
{
  "section": "不得不做的事",
  "title": "数据结构实验报告",
  "reason": "虽然你现在可能不是很想做事情，但是ddl马上要到啦，不妨试着从简单的一步先开始吧？",
  "todoId": "todo-1",
  "canAdd": false,
  "added": false
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `section` | string | 推荐分类标题：`"不得不做的事"` / `"适合现在状态的事"` / `"其他可以做的事"` |
| `title` | string | 推荐的待办标题或建议文字 |
| `reason` | string | 推荐理由 |
| `todoId` | string \| null | 关联的待办 ID（如果是已有待办） |
| `canAdd` | boolean | 是否可以添加到待办列表 |
| `added` | boolean | 用户是否已添加（客户端维护状态） |

推荐返回**恰好 3 条**：一条不得不做的事（ddl 最紧的未完成待办）、1-2 条适合当前状态的事、一条其他建议（`canAdd: true`）。

### 2.9 GoalSplitDraft（大目标拆分请求体）

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

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `title` | string | 是 | 不能为空 |
| `note` | string | 否 | 默认为 `""` |
| `finalDeadline` | datetime | 是 | 所有子目标的截止上限 |
| `subtasks` | array | 是 | 至少 1 个 |
| `subtasks[].title` | string | 是 | 不能为空 |
| `subtasks[].plannedDate` | date | 是 | 不得晚于 `finalDeadline` |

每个子目标创建为 `deadline` 类型待办，deadline = `plannedDate` 当天 **23:59**，默认优先级 **4**，默认标签 `["学习"]`。**所有子目标在同一事务中创建，任意失败全部回滚。**

### 2.10 SemesterSettings（学期设置）

```json
{
  "semesterStartDate": "2026-09-01",
  "periods": [
    { "period": 1, "start": "08:00", "end": "08:50" },
    { "period": 2, "start": "09:00", "end": "09:50" },
    { "period": 3, "start": "10:10", "end": "11:00" },
    { "period": 4, "start": "11:10", "end": "12:00" },
    { "period": 5, "start": "14:00", "end": "14:50" },
    { "period": 6, "start": "15:00", "end": "15:50" },
    { "period": 7, "start": "16:10", "end": "17:00" },
    { "period": 8, "start": "17:10", "end": "18:00" },
    { "period": 9, "start": "18:30", "end": "19:20" },
    { "period": 10, "start": "19:30", "end": "20:20" },
    { "period": 11, "start": "20:30", "end": "21:20" },
    { "period": 12, "start": "21:30", "end": "22:20" }
  ]
}
```

| 字段 | 类型 | 约束 |
|------|------|------|
| `period` | integer | 1-12 |
| `start` | string | `HH:mm` 格式 |
| `end` | string | `HH:mm` 格式 |

### 2.11 Tag（标签）

标签是纯字符串，无独立 ID。接口返回字符串数组：

```json
["考试", "作业", "讲座", "会议", "生活", "学习"]
```

预置标签（首次使用时自动创建）：`考试`、`作业`、`讲座`、`会议`、`生活`、`学习`。

创建或更新待办时，若携带的标签不存在于标签库中，**自动新增**。

---

## 3. API 接口

### 3.1 服务

#### `GET /health`

响应 `200`：

```json
{ "data": { "status": "ok" } }
```

#### `GET /api/v1/capabilities`

响应 `200`：

```json
{
  "data": {
    "storagePolicy": "local_first",
    "persistentUserData": [],
    "ephemeralProcessing": ["course_screenshot_recognition"],
    "optionalPersistentFeatures": [
      "client_encrypted_backup",
      "cross_device_sync",
      "share_export"
    ]
  }
}
```

用于客户端了解后端当前提供的服务能力和数据处理策略。

---

### 3.2 课程

#### `GET /api/v1/courses?week={week}`

查询指定教学周的课程。只有 `startWeek ≤ week ≤ endWeek` 且 `weekRule` 匹配的课程才会返回。

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `week` | integer | 是 | 1-25 |

`weekRule` 匹配逻辑：
- `all`：始终返回
- `odd`：week 为奇数时返回
- `even`：week 为偶数时返回

响应 `200`：

```json
{
  "data": [
    {
      "id": "course-...",
      "name": "微积分 II",
      "teacher": "",
      "location": "馆1-105",
      "note": "",
      "dayOfWeek": 1,
      "startPeriod": 1,
      "endPeriod": 2,
      "weekRule": "all",
      "startWeek": 1,
      "endWeek": 16,
      "colorKey": "purple",
      "source": "sample",
      "createdAt": "2026-04-01T00:00:00+08:00",
      "updatedAt": "2026-04-01T00:00:00+08:00"
    }
  ]
}
```

结果按 `dayOfWeek` → `startPeriod` → `endPeriod` → `name` 升序排列。

#### `POST /api/v1/courses`

创建课程。

请求体（除 `id`、`colorKey`、`source`、`createdAt`、`updatedAt` 外与 Course 模型相同）：

```json
{
  "name": "软件工程",
  "teacher": "陈老师",
  "location": "仙林 B406",
  "note": "小组项目",
  "dayOfWeek": 5,
  "startPeriod": 3,
  "endPeriod": 4,
  "weekRule": "all",
  "startWeek": 1,
  "endWeek": 16
}
```

校验规则：
- `name` 不能为空
- `location` 不能为空
- `dayOfWeek` 1-7
- 节次 1-12，`startPeriod ≤ endPeriod`
- 教学周 1-25，`startWeek ≤ endWeek`
- `weekRule` 必须是 `"all"` / `"odd"` / `"even"`

响应 `201`：

```json
{
  "data": {
    "id": "course-...",
    "name": "软件工程",
    "...": "..."
  }
}
```

#### `DELETE /api/v1/courses/{courseId}`

永久删除课程。响应 `204 No Content`（无响应体）。

若课程不存在，返回 `404`。

#### `POST /api/v1/courses/imports/screenshot`

> **第二阶段功能。** 当前返回静态占位数据。

使用 `multipart/form-data` 上传课表截图：

| 字段 | 类型 | 说明 |
|------|------|------|
| `file` | file | 图片文件（PNG / JPEG） |
| `week` | integer | 可选，当前教学周 |
| `semesterStart` | date | 可选，学期开学日期 |

后端识别课表并返回课程候选列表（**不直接写入数据库**，由用户在客户端确认后保存）：

响应 `200`：

```json
{
  "data": {
    "importId": "import-...",
    "status": "completed",
    "courses": [
      {
        "id": "course-...",
        "name": "人工智能导论",
        "teacher": "李老师",
        "location": "鼓楼 逸夫楼",
        "note": "由课表截图识别",
        "dayOfWeek": 2,
        "startPeriod": 9,
        "endPeriod": 10,
        "weekRule": "all",
        "startWeek": 1,
        "endWeek": 16,
        "colorKey": "indigo",
        "source": "screenshot",
        "createdAt": "...",
        "updatedAt": "..."
      }
    ]
  }
}
```

---

### 3.3 待办

#### `GET /api/v1/todos`

查询待办，支持筛选。

所有筛选参数均可选。不传任何参数时返回全部待办。

响应 `200`：

```json
{
  "data": [
    {
      "id": "todo-...",
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
  ]
}
```

**排序规则**（必须严格遵守）：

1. 未完成待办（`status = "open"`）排在已完成待办（`status = "done"`）之前
2. 每组内按 `deadlineAt ?? startAt` 升序排列
3. 两个值都为 `null` 的待办排在每组的**最后**

#### `POST /api/v1/todos`

创建待办。请求体见 [TodoDraft](#23-tododraft创建待办的请求体)。

校验规则：
- `title` 不能为空
- `priority` 0.0-5.0
- `kind = "duration"`：必须提供 `startAt` 和 `endAt`，且 `startAt < endAt`
- `kind = "deadline"`：必须提供 `deadlineAt`
- `kind = "normal"`：`startAt`、`endAt`、`deadlineAt` 应为 `null`
- 标签名称去除首尾空白后不能为空

响应 `201`：

```json
{ "data": { "...": "完整 TodoItem" } }
```

#### `PATCH /api/v1/todos/{todoId}`

更新待办。请求体见 [TodoPatch](#24-todopatch更新待办的请求体)。

若待办不存在，返回 `404`。

响应 `200`：

```json
{ "data": { "...": "更新后的完整 TodoItem" } }
```

#### `DELETE /api/v1/todos/{todoId}`

永久删除待办。响应 `204 No Content`。若不存在返回 `404`。

#### `POST /api/v1/todos/{todoId}/complete`

标记为已完成。本质是 `PATCH` 设置 `status = "done"`。

响应 `200`：

```json
{ "data": { "...": "更新后的 TodoItem（status = done）" } }
```

#### `POST /api/v1/todos/batch/delete`

请求体：

```json
{ "todoIds": ["todo-...", "todo-..."] }
```

响应 `204 No Content`。

#### `POST /api/v1/todos/batch/complete`

请求体：

```json
{ "todoIds": ["todo-...", "todo-..."] }
```

**必须跳过** `kind = "duration"` 的待办，不将其标记为完成。

响应 `200`：

```json
{
  "data": {
    "completedIds": ["todo-..."],
    "skippedIds": ["todo-..."]
  }
}
```

#### `GET /api/v1/todos/search?q={query}`

搜索待办。范围：`title`、`content`、`location`、`tags`。大小写不敏感。

响应 `200`（格式与 `GET /api/v1/todos` 相同）：

```json
{ "data": [ "...TodoItem 数组..." ] }
```

若 `q` 为空或空白，返回空数组。

#### `POST /api/v1/todos/recommendations`

> **第一阶段可复用本地规则，不是必须调用远程。**

请求体见 [RecommendationInput](#27-recommendationinput推荐请求体)。

响应 `200`：

```json
{
  "data": [
    {
      "section": "不得不做的事",
      "title": "数据结构实验报告",
      "reason": "虽然你现在可能不是很想做事情，但是ddl马上要到啦...",
      "todoId": "todo-1",
      "canAdd": false,
      "added": false
    },
    {
      "section": "适合现在状态的事",
      "title": "整理课堂笔记",
      "reason": "心情偏低时，先照顾好自己的状态，比硬撑更有效。",
      "todoId": "todo-2",
      "canAdd": false,
      "added": false
    },
    {
      "section": "其他可以做的事",
      "title": "今天早点睡",
      "reason": "实在不想动的话，今天早点睡，把事情交给明天状态更好的自己吧？",
      "todoId": null,
      "canAdd": true,
      "added": false
    }
  ]
}
```

推荐逻辑（本地规则版本）：
1. **不得不做的事**：`deadlineAt` 最近的未完成待办
2. **适合现在状态的事**：根据 mood 推荐普通待办
3. **其他可以做的事**：一条附加建议，`canAdd: true`

若用户没有任何待办，仍需返回 3 条推荐（使用文案占位，`todoId` 为空）。

#### `POST /api/v1/todos/goal-splits`

大目标拆分为多个待办。请求体见 [GoalSplitDraft](#29-goalsplitdraft大目标拆分请求体)。

校验规则：
- `title` 不能为空
- `subtasks` 至少 1 条
- 每条 `subtask.title` 不能为空
- 每条 `subtask.plannedDate` 不得晚于 `finalDeadline`

每个子目标创建为：
- `kind = "deadline"`
- `deadlineAt = plannedDate 当天 23:59`
- `priority = 4`
- `tags = ["学习"]`

**所有子目标在同一事务中创建，任意一条失败全部回滚。**

响应 `201`：

```json
{ "data": [ "...创建的 TodoItem 数组..." ] }
```

---

### 3.4 标签

#### `GET /api/v1/todo-tags`

响应 `200`：

```json
{ "data": ["考试", "作业", "讲座", "会议", "生活", "学习"] }
```

#### `POST /api/v1/todo-tags`

新增标签。

请求体：

```json
{ "name": "复习" }
```

`name` 去除首尾空白后不能为空。若标签已存在，直接返回已有标签（幂等）。

响应 `201`：

```json
{ "data": { "name": "复习" } }
```

---

### 3.5 设置

#### `GET /api/v1/settings/semester`

响应 `200`：

```json
{ "data": { "semesterStartDate": "2026-09-01" } }
```

#### `GET /api/v1/settings/periods`

响应 `200`：

```json
{
  "data": [
    { "period": 1, "start": "08:00", "end": "08:50" },
    { "period": 2, "start": "09:00", "end": "09:50" }
  ]
}
```

#### `PUT /api/v1/settings/semester`

> 待实现。请求体与 GET 响应相同。

#### `PUT /api/v1/settings/periods`

> 待实现。请求体与 GET 响应相同。

#### `POST /api/v1/settings/backup`

> 待实现。触发本地备份导出。

#### `POST /api/v1/exports`

> 待实现。创建分享导出。

---

## 4. 业务规则清单

以下规则必须在前后端**同时遵守**，否则会出现行为不一致：

### 4.1 待办排序

```
1. 未完成（open） 排在 已完成（done） 之前
2. 每组内按 (deadlineAt ?? startAt) 升序
3. 两个时间都为 null 的排在每组最后
```

### 4.2 批量完成

`POST /todos/batch/complete` 必须跳过 `kind = "duration"` 的待办。

### 4.3 标签自动入库

创建或更新待办时，若携带不存在的标签，自动加入标签库。

### 4.4 大目标拆分

- 事务性创建（全部成功或全部回滚）
- deadline = plannedDate 23:59
- 默认优先级 4，默认标签 `["学习"]`

### 4.5 颜色生成

课程颜色由课程名称稳定生成（哈希），不随机。

### 4.6 课程周次筛选

```
条件：startWeek ≤ week ≤ endWeek
      AND (weekRule 匹配)

weekRule 匹配：
  all  → 始终 true
  odd  → week % 2 == 1
  even → week % 2 == 0
```

### 4.7 搜索

- 范围：title、content、location、tags
- 大小写不敏感
- 结果按默认排序返回

### 4.8 筛选日期

日期筛选使用 `deadlineAt ?? startAt`（优先使用 deadlineAt）。

### 4.9 标签筛选

多个标签之间使用**任意匹配**（OR 逻辑），不是全部匹配（AND）。

---

## 5. 接口实施状态

| 接口 | 阶段 | 状态 |
|------|------|------|
| `GET /health` | 一 | 已实现 |
| `GET /api/v1/capabilities` | 一 | 已实现 |
| `GET /api/v1/courses` | 一 | 本地 Repository，不调远程 |
| `POST /api/v1/courses` | 一 | 本地 Repository，不调远程 |
| `DELETE /api/v1/courses/{id}` | 一 | 本地 Repository，不调远程 |
| `POST /api/v1/courses/imports/screenshot` | 二 | **待实现**（后端识别 + 前端真实上传） |
| `GET /api/v1/todos` | 一 | 本地 Repository，不调远程 |
| `POST /api/v1/todos` | 一 | 本地 Repository，不调远程 |
| `PATCH /api/v1/todos/{id}` | 一 | 本地 Repository，不调远程 |
| `DELETE /api/v1/todos/{id}` | 一 | 本地 Repository，不调远程 |
| `POST /api/v1/todos/{id}/complete` | 一 | 本地 Repository，不调远程 |
| `POST /api/v1/todos/batch/delete` | 一 | 本地 Repository，不调远程 |
| `POST /api/v1/todos/batch/complete` | 一 | 本地 Repository，不调远程 |
| `GET /api/v1/todos/search` | 一 | 本地 Repository，不调远程 |
| `POST /api/v1/todos/recommendations` | 一 | 本地规则推荐，不调远程 |
| `POST /api/v1/todos/goal-splits` | 一 | 本地 Repository，不调远程 |
| `GET /api/v1/todo-tags` | 一 | 本地 Repository，不调远程 |
| `POST /api/v1/todo-tags` | 一 | 本地 Repository，不调远程 |
| `GET /api/v1/settings/semester` | 一 | 本地 Repository，不调远程 |
| `GET /api/v1/settings/periods` | 一 | 本地 Repository，不调远程 |
| `PUT /api/v1/settings/semester` | 一 | 待实现 |
| `PUT /api/v1/settings/periods` | 一 | 待实现 |
| `POST /api/v1/settings/backup` | 一 | 待实现 |
| `POST /api/v1/exports` | 三 | 待实现 |

**关键理解**：第一阶段所有 CRUD 都在客户端本地完成，不经过 HTTP。后端在当前阶段只需保持 `/health` 和 `/capabilities` 可用，前端离线时不影响使用。

第二阶段开始，截图识别等远程接口上线后，前端需要新增 HTTP 调用。届时遵循本文档的接口格式即可。

---

## 6. 快速参考：前端对接 Check List

如果你在重写前端，确保你的代码满足以下条件，就可以无缝对接后端：

- [ ] 所有实体 ID 由客户端生成，格式为 `<type>-<UUID>`
- [ ] JSON 字段名使用 camelCase（如 `dayOfWeek`、`deadlineAt`）
- [ ] 枚举值使用全小写字符串（`"all"` 而非 `"ALL"` 或 `0`）
- [ ] 时间戳使用 ISO 8601 带时区（`2026-06-19T23:59:00+08:00`）
- [ ] PATCH 更新时，不修改的字段直接省略，要清空的字段显式传 `null`
- [ ] 待办排序：未完成在前 → `deadlineAt ?? startAt` 升序 → 无时间的最后
- [ ] 批量完成跳过 `duration` 类型
- [ ] 课程颜色根据名称稳定生成
- [ ] 课程周次筛选遵守 `weekRule` 匹配逻辑
- [ ] 标签筛选使用 OR 逻辑
- [ ] 搜索大小写不敏感
- [ ] 大目标拆分使用事务
- [ ] 后端不可用时，App 核心功能不崩溃
