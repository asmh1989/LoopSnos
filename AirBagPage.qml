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
                text: "气袋管理"
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
            width: parent.width * 0.6
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height * 0.7

            Column {
                anchors.fill: parent
                anchors.margins: 1

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    Text {
                        text: "气袋切换装置地址:"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: fff
                        font.pixelSize: 16
                        width: 300
                        Component.onCompleted: {
                            text = appSettings.val_url
                        }
                        anchors.verticalCenter: parent.verticalCenter

                        onEditingFinished: {
                        }
                    }

                    Button {
                        text: "保存"
                        onClicked: {
                            appSettings.val_url = fff.text
                            webSocket.close()
                            webSocket.open()
                        }
                    }
                }

                Item {
                    width: 1
                    height: 10
                }

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

                        spacing: 30
                        GrayLabel {
                            id: h_1
                            text: qsTr("开阀通道")
                            Layout.minimumWidth: 60
                        }
                        GrayLabel {
                            id: h_2
                            Layout.fillWidth: true
                            Layout.minimumWidth: 60
                            text: qsTr("气袋编号")
                        }
                        GrayLabel {
                            id: h_3
                            Layout.minimumWidth: 60
                            text: qsTr("气袋浓度")
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: header.parent.height * airBagsModel.length
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

                        model: airBagsModel
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
                                    text: modelData.airbag_no

                                    onEditingFinished: {
                                        airBagsModel[index].airbag_no = text
                                    }
                                }
                                MyInput {
                                    id: s_3
                                    width: h_3.width
                                    text: modelData.gas_conc
                                    onEditingFinished: {
                                        airBagsModel[index].gas_conc = text
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
                            saveJsonFile(Common.AIRBAG_CONFIG_PATH,
                                         airBagsModel)
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {

    }
}
