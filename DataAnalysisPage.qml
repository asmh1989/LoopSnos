import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "./view"
import "common.js" as Common

Page {
    header: ToolBar {
        id: bar
        width: parent.width
        RowLayout {
            spacing: 20
            anchors.fill: parent

            ToolButton {
                id: back
                action: navigateBackAction
                visible: true
            }

            Label {
                id: titleLabel
                text: "数据分析"
                font.pixelSize: 16
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            Item {
                width: back.width
            }
        }
    }

    padding: 20

    property var r1Arr
    property var r2Arr
    property var r3Arr
    property var r4Arr

    property int mySpacing: 16
    property int myWidth: 80
    property int myFontSize: 16

    Column {
        anchors.fill: parent
        spacing: 10
        Item {
            width: parent.width
            height: 170
            Item {
                id: r1
                width: 120
                height: parent.height
                anchors {
                    right: parent.right
                }
                Column {
                    anchors.centerIn: parent
                    width: parent.width
                    spacing: 6
                    Label {
                        width: parent.width
                        height: 30
                        color: 'white'
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        background: Rectangle {
                            anchors.fill: parent
                            color: Material.primary
                        }
                        text: "测试id"
                    }

                    TextField {
                        width: parent.width
                        id: testId
                        placeholderText: "1-3"
                    }
                }
            }
            Item {
                height: 140
                anchors {
                    left: parent.left
                    top: parent.top
                    right: r1.left
                }

                Column {
                    anchors.fill: parent
                    RowLayout {
                        height: parent.height / 4

                        Item {
                            width: 70
                            Text {
                                text: "仪器名称:"
                                font.pixelSize: myFontSize
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Repeater {
                            model: r1Arr
                            Layout.fillWidth: true
                            delegate: Item {
                                width: myWidth
                                height: parent.height
                                CheckBox {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.text
                                    checked: modelData.checked

                                    onCheckedChanged: {
                                        r1Arr[index].checked = checked
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        height: parent.height / 4

                        Item {
                            width: 70
                            Text {
                                text: "气路名称:"
                                font.pixelSize: 16
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Repeater {
                            model: r2Arr
                            Layout.fillWidth: true

                            delegate: Item {
                                width: myWidth
                                height: parent.height
                                CheckBox {
                                    text: modelData.text
                                    checked: modelData.checked
                                    anchors.verticalCenter: parent.verticalCenter

                                    onCheckedChanged: {
                                        r2Arr[index].checked = checked
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        height: parent.height / 4

                        Item {
                            width: 70
                            Text {
                                text: "传感器名称:"
                                font.pixelSize: myFontSize
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Repeater {
                            model: r3Arr
                            Layout.fillWidth: true
                            delegate: Item {
                                width: myWidth
                                height: parent.height
                                CheckBox {
                                    text: modelData.text
                                    checked: modelData.checked
                                    anchors.verticalCenter: parent.verticalCenter

                                    onCheckedChanged: {
                                        r3Arr[index].checked = checked
                                    }
                                }
                            }
                        }
                    }
                    RowLayout {
                        height: parent.height / 4

                        Item {
                            width: 70
                            Text {
                                text: "气袋浓度:"
                                font.pixelSize: myFontSize
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Repeater {
                            model: r4Arr
                            Layout.fillWidth: true
                            delegate: Item {
                                width: myWidth
                                height: parent.height
                                CheckBox {
                                    text: modelData.text
                                    checked: modelData.checked
                                    anchors.verticalCenter: parent.verticalCenter

                                    onCheckedChanged: {
                                        r4Arr[index].checked = checked
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Row {
            width: 400
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                text: "平均值AVG(ppb):"
                width: 160
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id: tfAvg
                enabled: false
            }
        }
        Row {
            width: 400
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                text: "绝对误差AE(ppb):"
                width: 160
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id: tfAE
                enabled: false
            }
        }
        Row {
            width: 400
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                text: "相对误差RE(%):"
                width: 160
                font.pixelSize: myFontSize
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id: tfRe
                enabled: false
            }
        }
        Row {
            width: 400
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                text: "标准偏差SD(ppb):"
                width: 160
                font.pixelSize: myFontSize
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id: tfSD
                enabled: false
            }
        }
        Row {
            width: 400
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                text: "相对标准偏差CW(%):"
                width: 160
                font.pixelSize: myFontSize
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id: tfCV
                enabled: false
            }
        }

        Button {
            text: "保存"
            width: 160
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Component.onCompleted: {
        r1Arr = sensorsModel.map(value => {
                                     return {
                                         "text": value.instrument_name,
                                         "checked": false
                                     }
                                 })
        r2Arr = sensorsModel.map(value => {
                                     return {
                                         "text": value.airLine_name,
                                         "checked": false
                                     }
                                 })
        r3Arr = sensorsModel.map(value => {
                                     return {
                                         "text": value.detector_name,
                                         "checked": false
                                     }
                                 })

        r4Arr = airBagsModel.map(value => {
                                     return {
                                         "text": value.gas_conc,
                                         "checked": false
                                     }
                                 })
    }
}
