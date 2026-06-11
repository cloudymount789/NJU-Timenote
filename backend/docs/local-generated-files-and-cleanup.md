# NJU Timenote 本地生成文件与清理指南

本文档记录开发、测试和运行 NJU Timenote 时，会在设备上新增的全部文件与目录，便于后期清理。

最后更新：2026-06-11

> **警告**：清理前请先关闭正在运行的 App、Flutter、Dart、Python 和 IDE 调试进程。

---

## 1. 风险分类

| 分类 | 含义 |
|------|------|
| 可安全删除 | 仅包含缓存或构建产物，删除后工具可重新生成 |
| 删除后需重建 | 包含开发环境或已下载工具，删除后需重新安装或重新构建 |
| 谨慎删除 | 包含用户数据，删除后数据无法恢复 |

---

## 2. App 运行时数据（谨慎删除）

### 2.1 Windows 本地数据库

Flutter Windows 桌面版运行时会在用户文档目录创建 SQLite 数据库：

```
C:\Users\PC\AppData\Roaming\com.example\nju_timenote\nju_timenote.sqlite
```

同时可能出现 SQLite 的 WAL（预写日志）和共享内存文件：

```
C:\Users\PC\AppData\Roaming\com.example\nju_timenote\nju_timenote.sqlite-wal
C:\Users\PC\AppData\Roaming\com.example\nju_timenote\nju_timenote.sqlite-shm
```

**路径来源**：`path_provider` 的 `getApplicationDocumentsDirectory()` 在 Windows 上返回 `%USERPROFILE%\Documents`。数据库文件名硬编码在 `app_database.dart:146`。

**包含内容**：课程、待办、标签、关联、学期设置、节次时间、搜索历史。所有用户数据。

**清除方式**：先退出 App，再删除 `.sqlite` 文件及 `.sqlite-wal` / `.sqlite-shm`。下次启动 App 时会自动重建数据库并写入 seed 数据。

**风险**：删除后所有手动添加的课程和待办将永久丢失。

### 2.2 Android / iOS / macOS / Linux 数据库

各平台拥有独立数据库，路径由 `getApplicationDocumentsDirectory()` 决定：

| 平台 | 典型路径 |
|------|---------|
| Android | `/data/data/com.example.nju_timenote/app_flutter/` |
| iOS/macOS | `~/Library/Containers/<bundle-id>/Data/Documents/` |
| Linux | `~/.local/share/nju_timenote/` |

卸载 App 或清除 App 数据会删除对应平台的数据库。

---

## 3. 项目仓库内的可清理目录

以下路径位于 `D:\MyProjects_TheTimeTableForNJU\NJU-Timenote\`。

### 3.1 Flutter 构建与工具缓存（可安全删除）

| 路径 | 说明 |
|------|------|
| `src\nju_timenote\.dart_tool\` | Dart 包配置、build_runner 缓存、Flutter 构建缓存 |
| `src\nju_timenote\build\` | Windows 及其他平台 Flutter 构建产物 |
| `src\nju_timenote\.flutter-plugins` | Flutter 插件注册（生成文件） |
| `src\nju_timenote\.flutter-plugins-dependencies` | Flutter 插件依赖清单 |

恢复方式：

```powershell
cd src\nju_timenote
flutter pub get
dart run build_runner build
```

或直接：

```powershell
flutter clean
flutter pub get
```

### 3.2 Python 虚拟环境（删除后需重建）

| 路径 | 说明 | 风险 |
|------|------|------|
| `backend\.venv\` | 独立 Python 虚拟环境 + 已安装的所有依赖 | 删除后需重建 |

重建方式：

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\python -m pip install -e ".[dev]"
```

### 3.3 Python 缓存（可安全删除）

| 路径 | 说明 |
|------|------|
| `backend\.pytest_cache\` | Pytest 测试缓存 |
| `backend\.ruff_cache\` | Ruff 代码检查缓存 |
| `backend\**\__pycache__\` | Python 字节码缓存（多个子目录） |
| `backend\nju_timenote_backend.egg-info\` | pip editable install 生成的包元数据 |
| `backend\htmlcov\` | 测试覆盖率报告（如有） |

---

## 4. 用户目录中的开发工具（删除后需重建）

### 4.1 Flutter SDK

```
C:\Users\PC\source\flutter\
```

这是 Flutter SDK 本体，不是 App 数据。删除后无法运行 `flutter` 和 `dart` 命令，需重新安装。

### 4.2 Dart / Flutter 包缓存

```
C:\Users\PC\AppData\Local\Pub\Cache\
```

保存从 pub.dev 下载的第三方包（Drift、Riverpod 等）。删除后 `flutter pub get` 需重新下载所有依赖。不包含项目源码或用户数据。

### 4.3 Android SDK（如有）

```
C:\Users\PC\AppData\Local\Android\Sdk\
```

Flutter Android 构建所需。删除后需通过 Android Studio 或 sdkmanager 重新安装。

---

## 5. 必须保留的项目生成文件

以下文件虽然由工具生成，但属于项目源码，**不应作为缓存删除**：

| 路径 | 生成方式 | 说明 |
|------|---------|------|
| `src\nju_timenote\lib\core\database\app_database.g.dart` | `dart run build_runner build` | Drift 数据库生成代码，未生成时项目无法编译 |
| `src\nju_timenote\pubspec.lock` | `flutter pub get` | 锁定依赖版本，确保团队构建一致 |
| `src\nju_timenote\windows\flutter\generated_plugin_registrant.*` | `flutter pub get` | Windows 平台插件注册 |
| `src\nju_timenote\linux\flutter\generated_plugin_registrant.*` | `flutter pub get` | Linux 平台插件注册 |
| `src\nju_timenote\macos\Flutter\GeneratedPluginRegistrant.swift` | `flutter pub get` | macOS 平台插件注册 |

---

## 6. 快速清理命令

### 只清理 Flutter 构建缓存（保留数据库）

```powershell
cd D:\MyProjects_TheTimeTableForNJU\NJU-Timenote\src\nju_timenote
flutter clean
flutter pub get
```

### 重建 Python 开发环境

```powershell
cd D:\MyProjects_TheTimeTableForNJU\NJU-Timenote\backend

# 删除所有 Python 相关缓存和环境
Remove-Item -Recurse -Force .venv, .pytest_cache, .ruff_cache, nju_timenote_backend.egg-info
Get-ChildItem -Recurse -Directory -Filter "__pycache__" | Remove-Item -Recurse -Force

# 重建
python -m venv .venv
.\.venv\Scripts\python -m pip install -e ".[dev]"
```

### 重置 Windows App 数据（删除数据库）

先关闭 App，然后：

```powershell
Remove-Item C:\Users\PC\AppData\Roaming\com.example\nju_timenote\nju_timenote.sqlite
# 也删除 WAL 文件（如果存在）
Remove-Item C:\Users\PC\AppData\Roaming\com.example\nju_timenote\nju_timenote.sqlite-wal -ErrorAction SilentlyContinue
Remove-Item C:\Users\PC\AppData\Roaming\com.example\nju_timenote\nju_timenote.sqlite-shm -ErrorAction SilentlyContinue
```

下次启动 App 时自动重建数据库并写入 seed 数据。

### 完全清除所有本地数据

```powershell
# 1. 关闭所有相关进程
# 2. 删除 App 数据库
Remove-Item C:\Users\PC\AppData\Roaming\com.example\nju_timenote\nju_timenote.sqlite*

# 3. 清理 Flutter 构建
cd D:\MyProjects_TheTimeTableForNJU\NJU-Timenote\src\nju_timenote
flutter clean

# 4. 清理 Python
cd D:\MyProjects_TheTimeTableForNJU\NJU-Timenote\backend
Remove-Item -Recurse -Force .venv, .pytest_cache, .ruff_cache, nju_timenote_backend.egg-info
Get-ChildItem -Recurse -Directory -Filter "__pycache__" | Remove-Item -Recurse -Force
```

---

## 7. 后续维护规则

引入新的工具、数据库、缓存或运行平台时，应更新本文档，至少记录：

- 实际路径（完整绝对路径）
- 创建来源（哪个工具、哪行代码）
- 是否包含用户数据
- 是否可以安全删除
- 删除后的影响
- 恢复或重新生成方式
