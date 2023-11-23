import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "common.js" as Common

Page {
    readonly property int space: 6
    property int space2: 6

    property var urls: []

    EventBus {
        id: bus
    }
    padding: space

    Row {
        anchors.fill: parent

        spacing: space
        Rectangle {
            width: parent.width - tool.width - space
            height: parent.height

            GridView {
                id: grid
                anchors.fill: parent
                cellWidth: (parent.width - 4) / 2
                cellHeight: (parent.height - 4) / 2
                model: urls

                delegate: SnoView {
                    width: grid.cellWidth - 4
                    height: grid.cellHeight - 4
                    sensorIndex: index
                    id: sno
                    url: urls[index]
                    border {
                        width: 4
                        color: 'lightGray'
                    }
                    anchors.margins: 2

                    Connections {
                        target: bus

                        function onMessageReceived(message, content) {
                            save_cache()
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
                            } else if (message === "Close") {
                                sno.close()
                            } else if (message === "Refresh") {
                                sno.refresh()
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: tool
            width: 320
            height: parent.height

            Column {
                anchors.fill: parent
                spacing: space2
                anchors.margins: 2

                Grid {
                    spacing: space2

                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalItemAlignment: Grid.AlignHCenter
                    verticalItemAlignment: Grid.AlignVCenter

                    Button {
                        text: "连接"
                        highlighted: true
                        onClicked: {
                            bus.sendMessage("Open")
                        }
                    }

                    Button {
                        text: "断开"
                        highlighted: true
                        onClicked: {
                            bus.sendMessage("Close")
                        }
                    }

                    Button {
                        text: "刷新"
                        highlighted: true
                        onClicked: {
                            bus.sendMessage("Refresh")
                        }
                    }
                }

                GridLayout {
                    width: parent.width
                    rows: 2
                    columns: 2
                    columnSpacing: space2
                    rowSpacing: space2

                    Label {
                        text: '开通阀门'
                        color: 'white'
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        background: Rectangle {
                            anchors.fill: parent
                            color: Material.primary
                        }
                    }

                    TextField {
                        id: tf_fm
                        placeholderText: "请输入"
                        text: appSettings.val_index + ""
                        Layout.maximumHeight: 40
                        validator: IntValidator {
                            bottom: 1
                            top: 8
                        }
                    }

                    Label {
                        text: '室内/箱内温度(°C)'
                        color: 'white'
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        background: Rectangle {
                            anchors.fill: parent
                            color: Material.primary
                        }
                    }

                    TextField {
                        id: tf_umd
                        placeholderText: "请输入"
                        Layout.maximumHeight: 40
                        text: appSettings.indoor_umd + ""

                        validator: DoubleValidator {
                            bottom: 5
                            top: 35
                            decimals: 1
                        }
                    }

                    Label {
                        text: '室内/箱内湿度(%)'
                        color: 'white'
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        background: Rectangle {
                            anchors.fill: parent
                            color: Material.primary
                        }
                    }

                    TextField {
                        id: tf_humi
                        placeholderText: "请输入"
                        Layout.maximumHeight: 40
                        text: appSettings.indoor_humi + ""

                        validator: IntValidator {
                            bottom: 1
                            top: 100
                        }
                    }
                }

                Button {
                    width: parent.width
                    text: "气袋管理"
                    onClicked: {
                        openAirBagPage()
                    }
                }

                Button {
                    width: parent.width
                    text: "检测器管理"

                    onClicked: {
                        openSensorsPage()
                    }
                }

                Label {
                    width: parent.width
                    text: "单次测试"
                    height: 40
                    color: 'white'
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    background: Rectangle {
                        anchors.fill: parent
                        color: Material.primary
                    }
                }
                Row {
                    Layout.fillWidth: true
                    spacing: space2
                    ComboBox {
                        id: cb
                        height: 40
                        model: ["Sno"]
                    }
                    Button {
                        text: '开始'
                        height: 40
                        onClicked: {
                            bus.sendMessage("Sno")
                        }
                    }

                    Button {
                        text: '停止'
                        height: 40

                        onClicked: {
                            bus.sendMessage("ForceStop")
                        }
                    }
                }

                Label {
                    width: parent.width
                    text: "离线循环"
                    height: 40
                    color: 'white'
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    background: Rectangle {
                        anchors.fill: parent
                        color: Material.primary
                    }
                }

                Row {
                    width: parent.width
                    height: 40
                    spacing: space2 / 2
                    Text {
                        text: "次数:"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: t_times
                        width: 40
                        height: 30
                        text: appSettings.offline_times
                        anchors.verticalCenter: parent.verticalCenter
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
                        width: 40
                        height: 30
                        anchors.verticalCenter: parent.verticalCenter
                        text: appSettings.offline_interval
                        validator: IntValidator {
                            bottom: 0
                            top: 9999
                        }
                    }
                    Button {
                        text: '开始'
                        height: 40

                        onClicked: {
                            bus.sendMessage("StartLoopTest")
                        }
                    }

                    Button {
                        text: '停止'
                        height: 40
                        onClicked: {
                            bus.sendMessage("StopLoopTest")
                        }
                    }
                }

                Button {
                    width: parent.width
                    text: "数据分析"
                }

                Button {
                    width: parent.width
                    text: "曲线分析"
                }
            }
        }
    }

    function save_cache() {
        appSettings.offline_times = parseInt(t_times.text)
        appSettings.offline_interval = parseInt(t_interval.text)

        appSettings.val_index = parseInt(tf_fm.text)
        appSettings.indoor_humi = parseInt(tf_humi.text)
        appSettings.indoor_umd = parseFloat(tf_umd.text)
    }

    Component.onCompleted: {

        sensorsModel.forEach(function (element) {
            urls.push(Common.fix_url(element.addr))
        })
        grid.model = urls
    }
}
