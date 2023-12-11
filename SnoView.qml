import QtQuick
import QtQuick.Controls

import QtCharts

import "common.js" as Common

Rectangle {
    property alias url: sm.url
    property alias type: sm.type
    property alias interval: sm.interval
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

    property bool easyUI: false
    property alias title: sm.title

    // 循环测试
    property int times: 0

    property string resultPbb: ""

    property int preIndex: appSettings.job_id

    function finish() {
        if (chart_timer.running) {
            resultPbb = getResultMsg("Sno")
            chart_timer.stop()
            refreshStatus()
            if (sm.currentStatus === Common.STATUS_END_FINISH) {
                save()
            }
            if (preIndex === appSettings.job_id) {
                appSettings.job_id += 1
            }
            console.log("finish sensorIndex = " + sensorIndex + " preIndex = "
                        + preIndex + " job_id = " + appSettings.job_id)
            reset_data()
            _start_time = 0

            eventBus.sendMessage(Common.MESSAGE_FINISH_ONE, sensorIndex)
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
        let obj = sm.sampleData
        if (obj && !isQc) {
            var trace_umd1_temp = obj[Common.UMD1_TEMP] / 100.0
            var func_status = obj[Common.FUNC_STATUS]

            var ambient_temp = obj[Common.AMBIENT_TEMP] / 100.0
            var ambient_humi = obj[Common.AMBIENT_HUMI]
            var sensor = sensorsModel[sensorIndex]
            var airbag = airBagsModel[appSettings.val_index]

            var flow_rt = arr_flow_rt.join(",") + ""
            var force = arr_force.join(",") + ""
            var umd = arr_umd1.join(",") + ""

            try {
                db.insertTestData(temperature, humidity,
                                  trace_umd1_temp, ambient_temp,
                                  ambient_humi, "Sno",
                                  preIndex, sensor.instrument_name,
                                  sensor.airLine_name, sensor.detector_name,
                                  airbag.airbag_no, airbag.gas_conc,
                                  resultPbb, flow_rt, force, umd,
                                  sensor.detector_no, sensor.sensor_no,
                                  sensor.sensor_standard)
                console.log("保存成功")
            } catch (e) {
                showToast("数据保存失败 = " + e)
            }
        }
    }

    function refreshStatus() {
        let obj = sm.sampleData
        let sensor_name = sensorsModel[sensorIndex].detector_name
        let d = sensor_name
        if (obj) {
            var trace_umd1_temp = obj[Common.UMD1_TEMP] / 100.0
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
            }
        }

        result.text = d
    }

    function getResultMsg(type) {
        var success = sm.currentStatus === Common.STATUS_END_FINISH
        var msg = ""

        if (success) {
            // 测试完成
            var len = arr_umd1.length
            if (len > 501) {
                var sensor = sensorsModel[sensorIndex]

                msg = calValue(arr_umd1,
                               sm.sampleData[Common.UMD1_TEMP] / 100.0,
                               sensor.sensor_standard)

                if (isQc) {
                    var qualityExpectedValue = getGasConc()
                    var n = msg * sensor.sensor_standard / qualityExpectedValue
                    console.log("n = " + n)
                    if (n > 2.0 && n < 6.0) {
                        sensor.sensor_standard = n.toFixed(4) + ""
                        // 更新校准灵敏度
                        sm.sendJson({
                                        "method": "update_sys_setting",
                                        "args": {
                                            "calibration_sensitivity": n
                                        }
                                    })
                        eventBus.sendMessage(
                                    Common.MESSAGE_ADD_LOG,
                                    sensor.airLine_name + "> 校准成功， 校准灵敏度 = " + n)
                    } else {
                        showToast(sensor.addr + " 校准失败， 校准灵敏度 = " + n, 10000)
                        eventBus.sendMessage(
                                    Common.MESSAGE_ADD_LOG,
                                    sensor.airLine_name + "> 校准失败， 校准灵敏度 = " + n)
                    }
                }
            } else {
                success = false
                msg = "帧数太少!"
                showToast(sensor.addr + " 离线测试失败！！！", 20000)

                eventBus.sendMessage(Common.MESSAGE_ADD_LOG,
                                     "离线测试失败: 帧数太少! addr = " + sensor.addr)
            }
        } else {
            msg = Common.get_status_info(sm.currentStatus)
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
                         var obj = sm.sampleData
                         var func_ack = obj[Common.FUNC_ACK]

                         // 未准备好
                         if (func_ack === 0 && flow_x === 0) {
                             return
                         }
                         // 结束
                         if (flow_x > 1 && Common.is_helxa_finish(
                                 sm.currentStatus)) {
                             sm.appendLog("测试结束 : " + Common.get_status_info(
                                              sm.currentStatus))
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
                     }
    }

    Timer {
        id: refresh_timer
        repeat: true
        interval: 1000
        onTriggered: () => {
                         if (!Common.is_helxa_finish(sm.currentStatus)) {
                             //                             console.log("refresh_timer refresh")
                             sm.refresh()
                         } else {
                             refresh_timer.stop()
                         }
                     }
    }

    function addFlowRt(obj) {
        var flow_rt = obj[Common.FLOW_RT] / 10.0

        var press_rt = obj[Common.PRESS_RT] / 10.0

        arr_force.push(press_rt)

        if (sm.currentStatus === Common.STATUS_FLOW1) {
            return
        }

        if (sm.currentStatus === Common.STATUS_FLOW2) {
            flow_rt = press_rt
        }

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

        console.log("start sensorIndex = " + sensorIndex + " preIndex = "
                    + preIndex + " job_id = " + appSettings.job_id)
    }

    Item {
        anchors.fill: parent

        ChartView {
            width: parent.width
            height: easyUI ? 0 : parent.height / 2
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
            height: easyUI ? parent.height : parent.height / 2
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
            visible: !easyUI
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
        id: sm
    }

    function startSno() {
        if (sm.is_open) {
            preTestDate = new Date()
            sm.start_helxa_test("Sno")
        }
    }

    function forceStop() {
        if (sm.is_open) {
            sm.stop_helxa_test()
        }
    }

    function open() {
        if (!sm.is_open) {
            sm.open()
        }
    }

    function close() {
        if (sm.is_open) {
            sm.close()
        }
    }

    function refresh() {
        if (sm.is_open) {
            sm.refresh()
        }
    }

    function startLoopTest() {
        if (sm.is_open) {
            if (!timer.running) {
                times = 0
                timer.start()
            } else {
                sm.appendLog("已在进行离线循环测试中!")
            }
        } else {
            eventBus.sendMessage(Common.MESSAGE_SOCKET_CONNECT, {
                                     "connected": false,
                                     "index": sensorIndex
                                 })

            stopLoopTest()
        }
    }
    function stopLoopTest() {
        timer.stop()
        timer2.stop()
        times = 0
        if (sm.exhaleStarting) {
            sm.stop_helxa_test()
        }
    }
    function _start_test() {
        times += 1
        var msg = "开始循环离线测试 times = " + times
        sm.appendLog(msg)
        startSno()
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
                if (!sm.inHelxa) {
                    // 结束后
                    timer.stop()
                    if (times === appSettings.offline_times) {
                        // 次数用完, 结束任务
                        sm.appendLog(appSettings.offline_times + "次循环离线测试完成!")
                        stopLoopTest()
                        eventBus.sendMessage(Common.MESSAFE_SLOOP_FINISH)
                    } else {
                        // 还有次数开启延时间隔执行
                        timer2.interval = Math.max(
                                    appSettings.offline_interval, 1) * 1000
                        sm.appendLog("延时离线循环定时器启动 .. " + timer2.interval)
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
        target: sm
        function onExhaleStartingChanged() {
            if (sm.exhaleStarting) {
                start()
            } else {
                finish()
            }
        }

        function onConnectReceived(msg) {
            connectTxt.text = sm.url + " " + msg
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
                    sm.close()
                    url = new_url
                    sm.sampleData = undefined
                    lines_umd1.clear()
                    chart.clear()
                }
                refreshStatus()
            }
        }
    }
}
