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

    property var dd: []

    property var result_header: ["仪器名称", "气路名称", "检测器名称", "气袋浓度/pbb", "ID", "平均值/ppb", "绝对误差/ppb", "相对误差/%", "标准偏差/ppb", "相对标准偏差/%"]

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
                        placeholderText: "id,id1-id2"

                        validator: RegularExpressionValidator {
                            regularExpression: /^[0-9]+(-[0-9]+)?(,[0-9]+(-[0-9]+)?)*$/
                        }

                        onTextChanged: {
                            // console.log("ids = " + Common.generateArrayFromString(
                            //                 text))
                        }
                    }

                    Button {
                        text: "刷新"
                        width: parent.width

                        onClicked: {
                            // var d = r4Arr.filter(v => v.checked)
                            // if (d.length === 0) {
                            //     showToast("请选择一个气袋浓度")
                            //     return
                            // }
                            var d = r3Arr.filter(v => v.checked)
                            if (d.length === 0) {
                                showToast("请选择一个传感器")
                                return
                            }
                            d = r2Arr.filter(v => v.checked)
                            if (d.length === 0) {
                                showToast("请选择一个气路")
                                return
                            }
                            d = r1Arr.filter(v => v.checked)
                            if (d.length === 0) {
                                showToast("请选择一个仪器")
                                return
                            }

                            if (gasTf.text.length === 0) {
                                showToast("请输入气袋浓度!")
                                return
                            }

                            getData()
                        }
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
                            id: r1R
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
                                        r1Arr.forEach(v => v.checked = false)
                                        r1Arr[index].checked = checked
                                        r1R.model = r1Arr
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
                            id: r2R
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
                                        r2Arr.forEach(v => v.checked = false)
                                        r2Arr[index].checked = checked
                                        r2R.model = r2Arr
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
                            id: r3R
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
                                        r3Arr.forEach(v => v.checked = false)
                                        r3Arr[index].checked = checked
                                        r3R.model = r3Arr
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
                        TextField {
                            id: gasTf
                            // placeholderText: "请输入气袋浓度"
                            Layout.preferredWidth: 200
                            font.pixelSize: 18
                            Layout.alignment: Qt.AlignVCenter
                        }

                        // Repeater {
                        //     id: gasR
                        //     model: r4Arr
                        //     Layout.fillWidth: true
                        //     delegate: Item {
                        //         width: myWidth
                        //         height: parent.height
                        //         CheckBox {
                        //             text: modelData.text
                        //             checked: modelData.checked
                        //             anchors.verticalCenter: parent.verticalCenter

                        //             onCheckedChanged: {
                        //                 r4Arr.forEach(v => v.checked = false)
                        //                 r4Arr[index].checked = checked
                        //                 gasR.model = r4Arr
                        //             }
                        //         }
                        //     }
                        // }
                    }
                }
            }
        }

        Row {
            width: 400
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                text: "查询到的IDS:"
                width: 160
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: tfIDS
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
                text: "相对标准偏差CV(%):"
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

            onClicked: {
                if (dd.length === 0) {
                    showToast("数据为空, 请重新设置筛选条件")
                    return
                }

                var d = dd[0]
                var ddd = dd.map(v => parseInt(v.job_id))
                var ids = "\"" + Common.convertToRangeString(ddd) + "\""

                // console.log("ids = " + ids + " " + JSON.stringify(ddd))
                var new_result = [d.instrument_name, d.airLine_name, d.detector_name, d.gas_conc, ids, tfAvg.text, tfAE.text, tfRe.text, tfSD.text, tfCV.text]

                var res = file.saveToCsv(getResultPrefix() + "/analysis.csv",
                                         result_header, [new_result])
                console.log("save = " + res)
            }
        }
    }

    function cal(v) {
        // var umds = v.no_rt.split(",").map(vv => parseInt(vv))
        // var sensor_standard = parseFloat(v.sensor_standard)
        // var td = parseFloat(v.td)
        var result = parseFloat(v.result)
        return result //parseFloat(calValue(umds, td, sensor_standard))
    }

    function refresh() {
        if (dd.length > 0) {
            var c = dd.map(v => cal(v))
            // var gas = parseInt(airBagsModel.filter(
            //                        (v, index) => r4Arr[index].checked).map(
            //                        v => v.gas_conc))
            var gas = parseFloat(gasTf.text)
            console.log("gas = " + gas)
            var m = Common.mean(c)
            var sd = Common.stdev(c)
            tfAvg.text = m.toFixed(1)
            tfAE.text = (m - gas).toFixed(1)
            tfRe.text = ((m - gas) / m * 100.0).toFixed(1) + "%"
            tfSD.text = sd.toFixed(1)
            tfCV.text = (sd / m * 100.0).toFixed(1) + "%"
        } else {
            if (tfAvg.text.length > 0) {
                showToast("数据为空, 请重新过滤数据")
            }
        }
        var ddd = dd.map(v => parseInt(v.job_id))
        var ids = Common.convertToRangeString(ddd)
        tfIDS.text = ids
    }

    function getData() {
        dd = db.queryTestData(r1Arr.filter(
                                  v => v.checked).map(v => "'" + v.text + "'"),
                              r2Arr.filter(v => v.checked).map(
                                  v => "'" + v.text + "'"), r3Arr.filter(
                                  v => v.checked).map(v => "'" + v.text + "'"),
                              "'" + gasTf.text + "'", Common.generateArrayFromString(
                                  testId.text))

        if (dd.length > 10) {
            dd = dd.slice(0, 10)
            showToast("数据过多, 只显示前10条")
        }

        refresh()
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
