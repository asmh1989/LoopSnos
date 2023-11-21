import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    readonly property int space: 4
    property var urls: []

    EventBus {
        id: bus
    }

    Row {
        anchors.fill: parent
        anchors.margins: space

        spacing: space
        Rectangle {
            width: parent.width - tool.width - space
            height: parent.height
            border {
                width: 1
                color: 'gray'
            }
            radius: 4

            GridView {
                id: grid
                anchors.fill: parent
                cellWidth: (parent.width - 4) / 2
                cellHeight: (parent.height - 4) / 2
                model: urls

                anchors.margins: 2
                delegate: SnoView {
                    width: grid.cellWidth
                    height: grid.cellHeight
                    id: sno
                    url: urls[index]
                    border {
                        width: 1
                        color: 'lightGray'
                    }
                    radius: 4

                    Connections {
                        target: bus

                        function onMessageReceived(message, content) {
                            if (message === "Sno") {
                                sno.startSno()
                            } else if (message === "ForceStop") {
                                sno.forceStop()
                            } else if (message === "Open") {
                                sno.open()
                            } else if (message === "StartLoopTest") {
                                sno.startLoopTest()
                            } else if (message === "StopLoopTest") {
                                sno.stopLoopTest()
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: tool
            width: parent.width / 5
            height: parent.height
            border {
                width: 1
                color: 'blue'
            }

            radius: 4

            Column {
                anchors.fill: parent
                spacing: 6
                anchors.margins: 2

                Button {
                    text: "ReConnect"

                    onClicked: {
                        bus.sendMessage("Open")
                    }
                }

                Button {
                    text: "StartSno"

                    onClicked: {
                        bus.sendMessage("Sno")
                    }
                }

                Button {
                    text: "ForceStop"

                    onClicked: {
                        bus.sendMessage("ForceStop")
                    }
                }

                Text {
                    text: "离线循环测试"
                }

                Row {
                    width: parent.width
                    height: 40
                    Text {
                        text: "次数:"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: t_times
                        text: appSettings.offline_times
                        validator: IntValidator {
                            bottom: 2
                            top: 999
                        }
                    }

                    Text {
                        text: "间隔(S):"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: t_interval
                        text: appSettings.offline_interval
                        validator: IntValidator {
                            bottom: 0
                            top: 9999
                        }
                    }
                }

                Row {

                    width: parent.width
                    spacing: 4
                    Button {
                        text: "离线循环"
                        onClicked: {
                            bus.sendMessage("StartLoopTest")
                        }
                    }

                    Button {
                        text: "结束循环"
                        onClicked: {
                            bus.sendMessage("StopLoopTest")
                        }
                    }
                }

                Text {
                    text: "UMD帧间隔"
                }

                Flow {
                    width: parent.width
                    spacing: 4
                    TextField {
                        id: t1
                        text: appSettings.umd_state1
                        height: 40
                        validator: IntValidator {
                            bottom: 0
                            top: 300
                        }
                    }
                    TextField {
                        id: t2
                        height: t1.height
                        text: appSettings.umd_state2
                        validator: IntValidator {
                            bottom: 50
                            top: 400
                        }
                    }
                    TextField {
                        id: t3
                        height: t1.height
                        text: appSettings.umd_state3
                        validator: IntValidator {
                            bottom: 350
                            top: 500
                        }
                    }
                    TextField {
                        id: t4
                        height: t1.height
                        text: appSettings.umd_state4
                        validator: IntValidator {
                            bottom: 450
                            top: 650
                        }
                    }
                }

                //                Row {
                //                    width: parent.width
                //                    height: 40
                //                    TextField {
                //                        id: t3
                //                        height: parent.height
                //                        text: appSettings.umd_state3
                //                        validator: IntValidator {
                //                            bottom: 350
                //                            top: 500
                //                        }
                //                    }
                //                    TextField {
                //                        id: t4
                //                        height: parent.height
                //                        text: appSettings.umd_state4
                //                        validator: IntValidator {
                //                            bottom: 450
                //                            top: 650
                //                        }
                //                    }
                //                }
            }
        }
    }

    function save_cache() {
        appSettings.offline_times = parseInt(t_times.text)
        appSettings.offline_interval = parseInt(t_interval.text)
        appSettings.umd_state1 = parseInt(t1.text)
        appSettings.umd_state2 = parseInt(t2.text)
        appSettings.umd_state3 = parseInt(t3.text)
        appSettings.umd_state4 = parseInt(t4.text)
    }

    Component.onCompleted: {
        urls.push("ws://192.168.2.33:8080")
        urls.push("ws://192.168.2.184:8080")
        urls.push("ws://192.168.2.77:8080")
        grid.model = urls
    }
}
