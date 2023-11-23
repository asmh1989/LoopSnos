import QtQuick
import QtQuick.Controls

import QtCharts

import "common.js" as Common

Rectangle {
    property alias url: manager.url
    property alias type: manager.type
    property alias interval: manager.interval
    property int sensorIndex: 0
    property real umd1_x: 0
    property int umd1_min_y: 0
    property int umd1_max_y: 0

    /// 用于画chart
    property int _start_time: 0
    property real flow_x: 0
    property int flow_min_y: 0

    property var arr_flow_rt: []
    property var arr_umd1: []
    property var arr_force: []

    // 循环测试
    property int times: 0

    property string resultPbb: ""

    property int preIndex: appSettings.job_id

    function finish() {
        if (chart_timer.running) {
            resultPbb = getResultMsg("Sno")
            chart_timer.stop()
            refreshStatus()
            reset_data()
            _start_time = 0
        }
    }

    function reset_data() {
        flow_x = 0
        umd1_x = 0
        arr_flow_rt.splice(0, arr_flow_rt.length)
        arr_umd1.splice(0, arr_umd1.length)
        arr_force.splice(0, arr_force.length)
    }

    function save() {
        let obj = manager.sampleData
        if (obj) {
            var trace_umd1_temp = obj[Common.TRACE_UMD1_TEMP] / 100.0
            var func_status = obj[Common.FUNC_STATUS]

            var ambient_temp = obj[Common.AMBIENT_TEMP] / 100.0
            var ambient_humi = obj[Common.AMBIENT_HUMI]
            var sensor = sensorsModel[sensorIndex]
            var airbag = airBagsModel[appSettings.val_index]

            var flow_rt = arr_flow_rt.join(",") + ""
            var force = arr_force.join(",") + ""
            var umd = arr_umd1.join(",") + ""

            db.insertTestData(appSettings.indoor_umd, appSettings.indoor_humi,
                              trace_umd1_temp, ambient_temp,
                              ambient_humi, "Sno",
                              preIndex, sensor.instrument_name,
                              sensor.airLine_name, sensor.detector_name,
                              airbag.airbag_no, airbag.gas_conc,
                              resultPbb, flow_rt, force, umd,
                              sensor.detector_no, sensor.sensor_no)
        }
    }

    function refreshStatus() {
        let obj = manager.sampleData
        let sensor_name = sensorsModel[sensorIndex].detector_name
        let d = sensor_name
        if (obj) {
            var trace_umd1_temp = obj[Common.TRACE_UMD1_TEMP] / 100.0
            var func_status = obj[Common.FUNC_STATUS]

            var ambient_temp = obj[Common.AMBIENT_TEMP] / 100.0
            var ambient_humi = obj[Common.AMBIENT_HUMI]
            var cas = airBagsModel[appSettings.val_index].gas_conc
            d = "TD:" + trace_umd1_temp + "°C TA:" + ambient_temp + "°C RH:"
                    + ambient_humi + "% " + sensor_name

            if (cas) {
                d = d + " " + cas + "ppb"
            }

            if (func_status === Common.STATUS_END_FINISH
                    && resultPbb.length > 0) {
                d = d + " 测试成功" + resultPbb + "ppb"
                save()
                if (preIndex === appSettings.job_id) {
                    appSettings.job_id += 1
                }
            }
        }

        result.text = d
    }

    function fix_umd(trace_umd1_temp, umd1) {
        var x = trace_umd1_temp - appSettings.umd_standard_temp
        var fix_xs = appSettings.standard_arg1 * x * x * x + appSettings.standard_arg2 * x
                * x + appSettings.standard_arg3 * x + appSettings.standard_arg4

        return (fix_xs * umd1).toFixed(2)
    }

    function fix_umd2(umd1) {
        return (umd1 / appSettings.umd_standard).toFixed(1)
    }

    function getResultMsg(type) {
        var success = manager.currentStatus === Common.STATUS_END_FINISH
        var msg = ""

        if (success) {
            // 测试完成
            var len = arr_umd1.length
            if (len > 501) {
                var lastElements = arr_umd1.slice(appSettings.umd_state1,
                                                  appSettings.umd_state2)
                var sum = lastElements.reduce(
                            (accumulator, currentValue) => accumulator + currentValue,
                            0)
                var av1 = sum / lastElements.length

                lastElements = arr_umd1.slice(appSettings.umd_state3,
                                              appSettings.umd_state4)
                sum = lastElements.reduce(
                            (accumulator, currentValue) => accumulator + currentValue,
                            0)
                var av2 = sum / lastElements.length
                var r = Math.abs(av1 - av2).toFixed(2)
                var fix_r = fix_umd(
                            manager.sampleData[Common.TRACE_UMD1_TEMP] / 100.0,
                            r)

                //                msg = "测试成功: 气袋浓度(" + appSettings.puppet_con + ") umd1均值差 = "
                //                        + fix_r + "/" + fix_umd2(fix_r) + " (ppb)"
                msg = fix_umd2(fix_r)

                //                save_to_file(r, fix_r, fix_umd2(fix_r))
            } else {
                success = false
                msg = "帧数太少!"
            }
        } else {
            msg = Common.get_status_info(manager.currentStatus)
        }

        if (!success) {
            msg = "测试失败: " + msg + "! 请重试"
        }

        //        toast.show(msg, 2000)
        return msg
    }

    Timer {
        id: chart_timer
        repeat: true
        interval: 100
        onTriggered: () => {
                         var obj = manager.sampleData
                         var func_ack = obj[Common.FUNC_ACK]

                         // 未准备好
                         if (func_ack === 0 && flow_x === 0) {
                             return
                         }
                         // 结束
                         if (flow_x > 1 && Common.is_helxa_finish(
                                 manager.currentStatus)) {
                             manager.appendLog(
                                 "测试结束 : " + Common.get_status_info(
                                     manager.currentStatus))
                             finish()
                             return
                         }

                         if (_start_time === 0) {
                             var update_time = new Date(obj[Common.UPDATE_TIME]).getTime()
                             _start_time = update_time
                             reset_data()
                             return
                         }

                         addFlowRt(obj)
                         addUmd1(obj)
                         arr_force.push(0)
                     }
    }

    Timer {
        id: refresh_timer
        repeat: true
        interval: 1000
        onTriggered: () => {
                         if (!Common.is_helxa_finish(manager.currentStatus)) {
                             //                             console.log("refresh_timer refresh")
                             manager.refresh()
                         } else {
                             refresh_timer.stop()
                         }
                     }
    }

    function addFlowRt(obj) {
        var flow_rt = obj[Common.FLOW_RT] / 10.0

        arr_flow_rt.push(flow_rt)

        var nums = chart_timer.interval / 100
        var len = Math.min(arr_flow_rt.length, nums)
        let lastElements = arr_flow_rt.slice(-len)
        let sum = lastElements.reduce(
                (accumulator, currentValue) => accumulator + currentValue, 0)
        let average = sum / len
        flow_x += chart_timer.interval / 1000

        if (flow_x > valueAxisX.max) {
            valueAxisX.max += 1
        }

        if (average > valueAxisY.max - 5) {
            valueAxisY.max += 10
        }

        if (average < valueAxisY.min + 5) {
            valueAxisY.min -= 10
        }

        chart.append(flow_x, average)
    }

    function addUmd1(obj) {
        var trace_umd1 = obj[Common.TRACE_UMD1]
        arr_umd1.push(trace_umd1)

        var nums = chart_timer.interval / 100
        var len = Math.min(arr_umd1.length, nums)
        let lastElements = arr_umd1.slice(-len)
        let sum = lastElements.reduce(
                (accumulator, currentValue) => accumulator + currentValue, 0)
        let average = sum / len
        umd1_x += chart_timer.interval / 1000

        if (umd1_x > umdAxisX.max) {
            umdAxisX.max += 1
        }

        if (umd1_min_y > average) {
            umd1_min_y = average
        }

        if (average > umd1_max_y) {
            umd1_max_y = average
        }

        umd1AxisY.min = Math.round(umd1_min_y - Math.abs(umd1_min_y) / 10 - 1)
        umd1AxisY.max = Math.ceil(umd1_max_y + Math.abs(umd1_max_y) / 10 + 1)

        lines_umd1.append(umd1_x, average)
    }

    function start() {
        result.text = ""
        lines_umd1.clear()
        chart.clear()
        umd1_min_y = 100000
        umd1_max_y = 0
        chart_timer.start()
        preIndex = appSettings.job_id
    }

    Item {
        anchors.fill: parent

        ChartView {
            width: parent.width
            height: parent.height / 2
            id: char_view
            antialiasing: true
            legend.visible: false

            LineSeries {
                id: chart
                axisX: valueAxisX
                axisY: valueAxisY
            }

            ValuesAxis {
                id: valueAxisX
                min: 0
                max: 10
                gridVisible: false
                labelFormat: "%.0f"
            }

            ValuesAxis {
                id: valueAxisY
                min: -10
                max: 60
                tickCount: 6
                labelFormat: "%.0f"
                titleText: "FLOW_RT (ml/s)"
            }
        }

        ChartView {
            anchors.top: char_view.bottom
            width: parent.width
            height: parent.height / 2
            id: chart_umd1
            antialiasing: true
            legend.visible: false

            LineSeries {
                id: lines_umd1
                axisX: umdAxisX
                axisY: umd1AxisY
            }

            ValuesAxis {
                id: umdAxisX
                min: 0
                max: 10
                gridVisible: false
                labelFormat: "%.0f"
            }

            ValuesAxis {
                id: umd1AxisY
                min: -10
                max: 60
                tickCount: 6
                labelFormat: "%.0f"
                titleText: "UMD1 (pbb)"
            }
        }
        Label {
            text: ""
            id: result
            height: 40
            color: 'white'
            anchors.centerIn: parent
            width: parent.width * 0.94
            padding: 6
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            background: Rectangle {
                anchors.fill: parent
                color: Material.primary
            }
        }

        Text {
            anchors.topMargin: 6
            color: 'red'
            id: connectTxt
            text: url
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
        }
    }

    EmSocketManager {
        id: manager
    }

    function startSno() {
        if (manager.is_open) {
            manager.start_helxa_test("Sno")
        }
    }

    function forceStop() {
        if (manager.is_open) {
            manager.stop_helxa_test()
        }
    }

    function open() {
        if (!manager.is_open) {
            manager.open()
        }
    }

    function close() {
        if (manager.is_open) {
            manager.close()
        }
    }

    function refresh() {
        if (manager.is_open) {
            manager.refresh()
        }
    }

    function startLoopTest() {
        if (!timer.running) {
            times = 0
            timer.start()
        } else {
            manager.appendLog("已在进行离线循环测试中!")
        }
    }
    function stopLoopTest() {
        timer.stop()
        timer2.stop()
        times = 0
        if (manager.exhaleStarting) {
            manager.stop_helxa_test()
        }
    }
    function _start_test() {
        times += 1
        var msg = "开始循环离线测试 times = " + times
        manager.appendLog(msg)
        manager.start_helxa_test("Sno")
    }

    Timer {
        id: timer
        triggeredOnStart: true
        interval: 1000
        repeat: true
        onTriggered: {
            if (times === 0) {
                // 开始第一次
                _start_test()
                return
            }

            if (times < appSettings.offline_times + 1) {
                if (!manager.inHelxa) {
                    // 结束后
                    timer.stop()
                    if (times === appSettings.offline_times) {
                        // 次数用完, 结束任务
                        manager.appendLog(
                                    appSettings.offline_times + "次循环离线测试完成!")
                        stop_test()
                    } else {
                        // 还有次数开启延时间隔执行
                        timer2.interval = Math.max(
                                    appSettings.offline_interval, 1) * 1000
                        manager.appendLog("延时离线循环定时器启动 .. " + timer2.interval)
                        timer2.start()
                    }
                }
            }
        }
    }

    Timer {
        id: timer2
        triggeredOnStart: false
        repeat: false
        interval: 1000
        onTriggered: {
            _start_test()
            timer.start()
        }
    }

    Connections {
        target: manager
        function onExhaleStartingChanged() {
            if (manager.exhaleStarting) {
                start()
            } else {
                finish()
            }
        }

        function onConnectReceived(msg) {
            connectTxt.text = manager.url + " " + msg
        }

        function onSampleDataChanged() {
            refreshStatus()
        }
    }

    Component.onCompleted: {
        refreshStatus()
    }

    Connections {
        target: eventBus

        function onMessageReceived(msg) {
            if (msg === Common.MESSAGE_REFRESH_CONFIG) {
                var new_url = Common.fix_url(sensorsModel[sensorIndex].addr)
                if (new_url !== (url + "")) {
                    manager.close()
                    url = new_url
                    manager.sampleData = undefined
                    lines_umd1.clear()
                    chart.clear()
                }
                refreshStatus()
            }
        }
    }
}
