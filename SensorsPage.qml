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
                text: "检测器管理"
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

    Item {
        anchors.fill: parent
        anchors.margins: 20
        Rectangle {
            width: parent.width
            height: parent.height * 0.7

            //            border {
            //                width: 1
            //                color: 'gray'
            //            }
            Column {
                anchors.fill: parent
                anchors.margins: 1

                Rectangle {
                    width: parent.width
                    color: '#cecece'
                    height: header.height + header.anchors.margins * 3 / 2

                    RowLayout {
                        id: header
                        width: parent.width - anchors.margins * 2
                        height: 46
                        anchors.centerIn: parent
                        anchors.margins: 10
                        anchors.left: parent.left

                        spacing: 6
                        GrayLabel {
                            id: h_1
                            text: qsTr("序号")
                            Layout.minimumWidth: 60
                        }
                        GrayLabel {
                            id: h_2
                            Layout.fillWidth: true
                            Layout.minimumWidth: 120
                            text: qsTr("地址")
                        }
                        GrayLabel {
                            id: h_3
                            Layout.minimumWidth: 60
                            text: qsTr("仪器名称")
                        }

                        GrayLabel {
                            id: h_4
                            Layout.minimumWidth: 60
                            text: qsTr("气路名称")
                        }

                        GrayLabel {
                            id: h_5
                            Layout.minimumWidth: 60
                            text: qsTr("检测器名称")
                        }

                        GrayLabel {
                            id: h_6
                            Layout.fillWidth: true
                            Layout.minimumWidth: 60
                            text: qsTr("检测器编号")
                        }

                        GrayLabel {
                            id: h_7
                            Layout.fillWidth: true
                            Layout.minimumWidth: 60
                            text: qsTr("传感器编号")
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: header.parent.height * 4
                    border {
                        width: 1
                        color: 'lightGray'
                    }

                    ListView {
                        id: listView
                        anchors.fill: parent
                        boundsBehavior: Flickable.StopAtBounds
                        boundsMovement: Flickable.StopAtBounds
                        clip: true

                        model: sensorsModel
                        delegate: Column {
                            height: header.parent.height
                            width: parent.width

                            Item {
                                height: 6
                                width: parent.width
                            }

                            Row {
                                width: parent.width - anchors.margins * 2
                                height: parent.height - 12
                                anchors.margins: 10
                                anchors.left: parent.left
                                spacing: header.spacing

                                MyInput {
                                    id: s_1
                                    width: h_1.width
                                    text: (index + 1) + ""
                                    enabled: false
                                }
                                MyInput {
                                    id: s_2
                                    width: h_2.width
                                    text: modelData.addr

                                    onEditingFinished: {
                                        sensorsModel[index].addr = text
                                    }
                                }
                                MyInput {
                                    id: s_3
                                    width: h_3.width
                                    text: modelData.instrument_name
                                    onEditingFinished: {
                                        sensorsModel[index].instrument_name = text
                                    }
                                }

                                MyInput {
                                    id: s_4
                                    width: h_4.width
                                    text: modelData.airLine_name
                                    onEditingFinished: {
                                        sensorsModel[index].airLine_name = text
                                    }
                                }

                                MyInput {
                                    id: s_5
                                    width: h_5.width
                                    text: modelData.detector_name
                                    onEditingFinished: {
                                        sensorsModel[index].detector_name = text
                                    }
                                }
                                MyInput {
                                    id: s_6
                                    width: h_6.width
                                    text: modelData.detector_no
                                    onEditingFinished: {
                                        sensorsModel[index].detector_no = text
                                    }
                                }
                                MyInput {
                                    id: s_7
                                    width: h_7.width
                                    text: modelData.sensor_no
                                    onEditingFinished: {
                                        sensorsModel[index].sensor_no = text
                                    }
                                }
                            }
                            Item {
                                height: 5
                                width: parent.width
                            }
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: 'lightGray'
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: parent.height * 0.2
                    Button {
                        anchors.centerIn: parent
                        text: "保存"

                        onClicked: {
                            saveJsonFile(Common.SENSORS_CONFIG_PATH,
                                         sensorsModel)
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {

    }
}
