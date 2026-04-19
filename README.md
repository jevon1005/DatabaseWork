# RailwaySystem — 高铁订票系统

基于 **Qt 6（QML + C++）** 的 Windows 桌面客户端，业务数据持久化到 **PostgreSQL**（可对接 **Supabase**），并支持 **`data/` 本地快照** 作为离线回退与加速启动。

---

## 功能概览

| 角色 | 能力 |
|------|------|
| **普通用户** | 注册/登录、个人信息与密码、车票查询（城市+日期）、余票与票价、下单与自动选座、我的订单（取消/改签）、乘车人管理 |
| **管理员** | 车次与时刻表维护、座席模板、全量订单与用户/管理员账户管理（含锁定） |

详细需求、库表与架构说明见 **[项目开发文档.md](./项目开发文档.md)**。

---

## 仓库结构（与当前代码一致）

```
RailwaySystem/
├── CMakeLists.txt              # CMake 工程，目标可执行文件 appRailwaySystem
├── main.cpp                    # 入口：数据库连接、Manager 注入 QML、退出同步
├── images.qrc                  # QML 与图片等资源清单
├── qml/
│   ├── main.qml                # 主窗口：侧栏 + StackView + 登录层
│   ├── Splash.qml              # 启动页与 DataLoader 进度
│   ├── SessionState.qml        # 登录态单例（username / role / isLoggedIn）
│   ├── pages/                  # 各业务页面（登录、查询、订单、管理等）
│   └── components/             # 可复用 UI 组件
├── resources/
│   ├── images/                 # 如 logbackground.png
│   └── icon/                   # 侧栏与按钮图标
├── data/                       # 本地快照（city/station/train/user/passenger/order 等 .txt）
├── supabase/
│   ├── 001_core_tables.sql     # 核心表结构
│   └── 002_desktop_app_columns.sql
├── softwareTest/               # 测试报告（LaTeX 等）
├── scripts/
│   └── generate_defense_ppt.py # 生成答辩用 PPT（需 python-pptx）
├── docs/
│   └── 答辩汇报.pptx           # 运行脚本后生成（若已生成）
├── railway_debug_pg.ini.example
└── 项目开发文档.md
```

核心 C++ 模块：`bookingsystem`、`accountmanager`、`stationmanager`、`trainmanager`、`ordermanager`、`passengermanager`、`dataloader`、`railway_pg_connection` 等（见 `CMakeLists.txt`）。

---

## 构建要求

- **CMake** ≥ 3.16  
- **Qt 6.8+**，模块：Gui、Qml、Quick、QuickControls2、Sql、Core5Compat  
- 构建时需启用 **PostgreSQL 客户端驱动对应的 QPSQL** 插件（`QSqlDatabase::drivers()` 含 `QPSQL`）

```bash
cmake -B build -DCMAKE_PREFIX_PATH=<Qt6安装路径>
cmake --build build --config Release
```

生成可执行文件：`build/Release/appRailwaySystem.exe`（或 Debug 目录，视生成器而定）。

---

## 数据库配置

1. 在 Supabase 或自建 PostgreSQL 中执行 `supabase/001_core_tables.sql` 与 `002_desktop_app_columns.sql`。  
2. 任选其一配置连接：  
   - **环境变量**：`PGHOST`、`PGPORT`、`PGDATABASE`、`PGUSER`、`PGPASSWORD`、`PGSSLMODE`  
   - **INI 文件**：复制 `railway_debug_pg.ini.example` 为 `railway_debug_pg.ini` 并填写 `[postgres]` 段（该文件已 `.gitignore`）

辅助脚本（PowerShell）：`setup_database.ps1`、`test_connection.ps1`、`check_pg_driver.ps1` 等。

---

## 运行说明

- 首次启动：`Splash` 后台线程拉取云端数据并写入 `data/` 快照；连接失败时使用本地快照。  
- 退出：保存本地缓存；若库可用且内存数据有变更，则写回 PostgreSQL。

---

## 答辩 PPT 生成

需 **Python 3** 与 **python-pptx**：

```powershell
pip install python-pptx
python scripts/generate_defense_ppt.py
```

输出：`docs/答辩汇报.pptx`。可在 PowerPoint / WPS 中打开后继续替换封面姓名、补充截图。

---

## 许可证与说明

课程/实训项目用途；生产环境部署前请自行加固认证、密码存储与网络安全策略。
