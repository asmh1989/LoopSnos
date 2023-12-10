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

    property var flowArr
    property var pressArr
    property var noArr

    property int mySpacing: 16
    property int myWidth: 80
    property int myFontSize: 16

    property var dd: []

    property var xx: []

    property int alreadyIndex: 0
    property int oneTimePaintPoints: 60

    ColumnLayout {
        anchors.fill: parent
        Item {
            id: hh
            Layout.fillWidth: true
            height: 130
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
                        placeholderText: "id,id1-id2"

                        validator: RegularExpressionValidator {
                            regularExpression: /^[0-9]+(-[0-9]+)?(,[0-9]+(-[0-9]+)?)*$/
                        }

                        onTextChanged: {
                            console.log("ids = " + Common.generateArrayFromString(
                                            text))
                        }
                    }

                    Button {
                        text: "刷新"

                        onClicked: {
                            getData()
                        }
                    }
                }
            }
            Item {
                id: ll
                height: 120
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

        AutoYChartView {
            id: chart1
            Layout.fillHeight: true
            Layout.fillWidth: true
            titleText: "Press (hpa)"
            rightYVisible: false
        }
        AutoYChartView {
            id: chart2
            Layout.fillWidth: true
            Layout.fillHeight: true
            rightYVisible: false
            titleText: "FLOW (ml/s)"
        }
        AutoYChartView {
            id: chart3
            Layout.fillWidth: true
            Layout.fillHeight: true
            rightYVisible: false
            titleText: "UMD1 (ppb)"
        }
    }

    function clear() {
        chart1.removeAllSeries()
        chart2.removeAllSeries()
        chart3.removeAllSeries()
        flowArr = []
        pressArr = []
        noArr = []
        xx = []
        alreadyIndex = 0
    }

    function refresh() {
        timer.start()
    }

    function getData() {
        dd = db.queryTestData(r1Arr.filter(
                                  v => v.checked).map(v => "'" + v.text + "'"),
                              r2Arr.filter(v => v.checked).map(
                                  v => "'" + v.text + "'"), r3Arr.filter(
                                  v => v.checked).map(v => "'" + v.text + "'"),
                              r4Arr.filter(v => v.checked).map(
                                  v => "'" + v.text + "'"), Common.generateArrayFromString(
                                  testId.text))
        clear()
        dd.forEach((v, index) => {
                       flowArr.push(v.flow_rt.split(','))
                       pressArr.push(v.press_rt.split(','))
                       noArr.push(v.no_rt.split(','))
                       chart1.createSeries(v.job_id + "_" + v.instrument_name)
                       chart2.createSeries(v.job_id + "_" + v.instrument_name)
                       chart3.createSeries(v.job_id + "_" + v.instrument_name)
                       xx.push(0.0)
                   })
        refresh()
    }

    Timer {
        id: timer
        repeat: true
        interval: 100
        triggeredOnStart: true
        onTriggered: {
            var old = alreadyIndex
            var size = dd.length

            dd.forEach((v, index2) => {
                           var len = Math.min(Math.min(
                                                  flowArr[index2].length,
                                                  pressArr[index2].length),
                                              noArr[index2].length)

                           if (old > len - 1) {
                               size -= 1
                               return
                           }

                           var flow = flowArr[index2].slice(
                               old, Math.min(len - 1, old + oneTimePaintPoints))
                           var press = pressArr[index2].slice(
                               old, Math.min(len - 1, old + oneTimePaintPoints))
                           var no = noArr[index2].slice(
                               old, Math.min(len - 1, old + oneTimePaintPoints))
                           flow.forEach((v, index) => {
                                            chart2.add(xx[index2],
                                                       flow[index], index2)
                                            chart1.add(xx[index2],
                                                       press[index], index2)
                                            chart3.add(xx[index2],
                                                       no[index], index2)
                                            xx[index2] += 0.1
                                        })
                       })
            if (size === 0) {
                timer.stop()
            } else {
                alreadyIndex += oneTimePaintPoints
            }
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

        getData()
    }
}
