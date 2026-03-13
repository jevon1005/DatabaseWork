import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: control

    // 搜索文本
    property string searchText: ""

    // 列表项样式配置
    property int itemHeight: 40
    property int itemFontSize: 15

    // 新增：下拉列表最大高度
    property int popupMaxHeight: 400

    // 内部使用的过滤后的模型
    property var filteredModel: model

    onModelChanged: {
        updateFilteredModel()
    }

    function updateFilteredModel() {
        if (!model) return

        if (searchText === "") {
            filteredModel = model
        } else {
            var result = []
            for (var i = 0; i < model.length; i++) {
                // 简单的包含匹配
                if (model[i].indexOf(searchText) !== -1) {
                    result.push(model[i])
                }
            }
            filteredModel = result
        }
    }

    // 自定义 Popup
    popup: Popup {
        y: control.height - 1
        width: control.width
        height: Math.min(listView.contentHeight + 60, control.popupMaxHeight) // 增加一点最大高度
        padding: 1

        background: Rectangle {
            color: "#ffffff"
            border.color: "#e0e0e0"
            radius: 4
        }

        contentItem: Column {
            spacing: 0

            // 搜索框区域
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"
                z: 2

                TextField {
                    id: searchField
                    anchors.centerIn: parent
                    width: parent.width - 20
                    height: control.itemHeight
                    placeholderText: "搜索..."
                    font.pixelSize: control.itemFontSize
                    leftPadding: 10
                    background: Rectangle {
                        color: "#f5f5f5"
                        radius: 4
                        border.width: 1
                        border.color: searchField.activeFocus ? "#3498db" : "#e0e0e0"
                    }
                    onTextChanged: {
                        control.searchText = text
                        control.updateFilteredModel()
                    }
                }
            }

            // 列表视图
            ListView {
                id: listView
                width: parent.width
                height: control.popup.height - 60
                clip: true
                model: control.filteredModel

                delegate: ItemDelegate {
                    width: listView.width
                    height: control.itemHeight

                    contentItem: Text {
                        text: modelData
                        font.pixelSize: control.itemFontSize
                        color: hovered ? "#3498db" : "#222"
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                    }

                    background: Rectangle {
                        color: hovered ? "#f0f8ff" : "transparent"
                    }

                    onClicked: {
                        // 找到原始模型中的索引
                        var originalIndex = control.model.indexOf(modelData)
                        if (originalIndex !== -1) {
                            control.currentIndex = originalIndex
                        }
                        control.popup.close()
                    }
                }

                ScrollBar.vertical: ScrollBar { }
            }
        }

        onOpened: {
            searchField.text = ""
            searchField.forceActiveFocus()
            control.updateFilteredModel()
        }
    }
}
