# NJU-Timenote

NJU Timenote 是一个 Flutter 前端项目。前端工程集中放在 `frontend/`，根目录保留产品文档、接口契约、交互说明和 Pencil 原型。

当前 Flutter 前端已包含首页、课表、待办、搜索、下一件事推荐、大目标拆分和设置最小入口。业务数据通过 repository 调用本地 source，并使用 `shared_preferences` 保存 JSON 快照，App 重启后课程、待办、标签和设置仍可读取；尚未接入后端 HTTP、登录、云同步或真实 AI 服务。

## 目录

- `frontend/`：Flutter Android 前端工程。
- `docs/`：协作规约、功能范围、路线图、接口契约、代码地图和手测清单。
- `UI/nju-timenote.pen`：Pencil 高保真原型。

## 当前能力边界

- 课表、待办、标签、设置、推荐和大目标拆分均可在设备本地使用。
- 课程、待办、标签、课程颜色映射、待办排序状态和重复完成记录会保存在本地，重启 App 后仍保留。
- 一句话创建、下一件事推荐和大目标拆分为前端本地临时策略，不调用真实 AI。
- 截图添加课程是流程壳，当前提示识别服务未接入。
- 后端契约见 `docs/frontend-backend-contract.md`；当前实现差异记录在该文档附录。

## 常用命令

以下命令都在 `frontend/` 目录执行：

```powershell
cd frontend
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

如果本机 PowerShell 里 Gradle 找不到 Java，请先临时设置 Android Studio 自带 JDK：

```powershell
$env:JAVA_HOME='D:\Program Files\Android Studio\jbr'
$env:PATH="$env:JAVA_HOME\bin;$env:PATH"
```

## 思源宋体

当前主题已优先使用 `Source Han Serif SC`。仓库已放入 Adobe 官方 Source Han Serif 2.003R 的简体中文 OTF 常用字重：Regular、SemiBold、Bold。字体文件和 SIL Open Font License 位于 `frontend/assets/fonts/`，并已在 `frontend/pubspec.yaml` 中注册。
