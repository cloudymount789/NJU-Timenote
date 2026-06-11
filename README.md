# NJU-Timenote

NJU Timenote 是一个 Flutter 前端项目。前端工程集中放在 `frontend/`，根目录保留产品文档、接口契约、交互说明和 Pencil 原型。

## 目录

- `frontend/`：Flutter Android 前端工程。
- `docs/`：协作规约、功能范围、路线图、接口契约、代码地图和手测清单。
- `UI/nju-timenote.pen`：Pencil 高保真原型。

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
