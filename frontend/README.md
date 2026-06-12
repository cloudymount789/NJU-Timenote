# NJU Timenote 前端

这是 NJU Timenote 的 Flutter 前端工程，当前主要支持 Android，并已生成 Windows 桌面工程入口用于本地预览。

## 开始使用

进入前端目录：

```powershell
cd frontend
```

获取依赖：

```powershell
flutter pub get
```

运行到已连接的 Android 设备、模拟器或 Windows 桌面：

```powershell
flutter run
```

常用检查命令：

```powershell
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

## 当前边界

- 当前不接真实后端、登录、云同步或真实 AI。
- UI 不直接访问 HTTP、本地数据库或文件存储，业务访问统一经过 repository/source 边界。
- 视觉和交互要求以 `docs/interaction.md`、`docs/frontend-roadmap.md` 和 Pencil 原型为准。
