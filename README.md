RailwaySystem/
├── CMakeLists.txt
├── appRailwaySystem/
│   ├── main.cpp                 # C++ 程序入口
│   ├── qml.qrc                  # QML 和图片资源清单（可以合并到一起）
│   ├── qml/                     # 所有 QML 文件（前端页面与组件）
│   │   ├── main.qml             # QML 启动入口
│   │   ├── pages/               # 多页面专用目录
│   │   │   ├── Login.qml
│   │   │   ├── Home.qml
│   │   │   └── ...              # 其它页面
│   │   ├── components/          # 通用组件
│   │   │   └── CustomButton.qml
│   │   └── ...                  # 其它QML代码
│   ├── resources/               # 静态资源
│   │   └── images/
│   │       └── xxx.png
│   └── ...                      # 其它如头文件、逻辑代码