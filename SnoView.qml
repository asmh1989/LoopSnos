import QtQuick
import QtQuick.Controls

import "common.js" as Common
import "./view"

Rectangle {
    property alias url: sm.url
    property alias type: sm.type
    property alias interval: sm.interval
    property int sensorIndex: 0
    property real umd1_x: 0

    /// 用于画chart
    property int _start_time: 0
    property real flow_x: 0

    property bool easyUI: false
    property alias title: sm.title

    // 循环测试
    property int times: 0

    property string resultPbb: ""

    property int preIndex: appSettings.job_id
    property int retryTimes: 0
    property int finishTimes: 0

    function appendLog(msg) {
        eventBus.sendMessage(Common.MESSAGE_ADD_LOG, msg)
    }

    function finish() {
        if (!sm.is_open && sm.arr_umd1.length === 0) {
            return
        }

        if (Common.is_helxa_finish(sm.currentStatus)) {
            getResultMsg()
            refreshStatus()

            if (preIndex === appSettings.job_id) {
                appSettings.job_id += 1
            }

            _start_time = 0

            if (sm.currentStatus === Common.STATUS_END_FINISH
                    && sm.arr_umd1.length > 100) {
                try {
                    appendLog("finish sensorIndex = " + sensorIndex + " preIndex = "
                              + preIndex + " job_id = " + appSettings.job_id)
                    eventBus.sendMessage(Common.MESSAGE_FINISH_ONE, sensorIndex)
                    save()
                } catch (e) {
                    appendLog("数据库存储失败")
                }
            } else {
                appendLog("工作异常, sensorIndex = " + sensorIndex + " preIndex = "
                          + preIndex + " job_id = " + appSettings.job_id + "  开始重试!!")
                times -= 1
            }

            reset_data()
        } else {
            console.log("忽略, status = " + sm.currentStatus)
        }
    }

    function restart() {
        chart_timer.stop()
        finishTimes = 1
        reset_data()
    }

    function reset_data() {
        flow_x = 0
        umd1_x = 0
        sm.arr_flow_rt.splice(0, sm.arr_flow_rt.length)
        sm.arr_umd1.splice(0, sm.arr_umd1.length)
        sm.arr_baseline.splice(0, sm.arr_baseline.length)
        sm.arr_force.splice(0, sm.arr_force.length)
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

            var flow_rt = sm.arr_flow_rt.join(",") + ""
            var force = sm.arr_force.join(",") + ""
            var umd = sm.arr_umd1.join(",") + ""
            var baseline = sm.arr_baseline.join(",") + ""

            try {
                db.insertTestData(temperature, humidity,
                                  trace_umd1_temp, ambient_temp,
                                  ambient_humi, "Sno",
                                  preIndex, sensor.instrument_name,
                                  sensor.airLine_name, sensor.detector_name,
                                  airbag.airbag_no, airbag.gas_conc,
                                  resultPbb, flow_rt, force, umd,
                                  baseline, sensor.detector_no,
                                  sensor.sensor_no, sensor.sensor_standard)
                appendLog("保存成功")
            } catch (e) {
                appendLog("数据保存失败 = " + e)
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
                d = d + " 测试成功 " + resultPbb + "ppb"
            }
        }

        result.text = d
    }

    function getResultMsg() {
        var success = sm.currentStatus === Common.STATUS_END_FINISH
        var msg = ""

        if (success) {
            // 测试完成
            var sensor = sensorsModel[sensorIndex]

            msg = resultPbb

            if (isQc) {
                var qualityExpectedValue = getGasConc()
                var n = msg * sensor.sensor_standard / qualityExpectedValue
                console.log("n = " + n)
                if (n > 2.0 && n < 6.0) {
                    sensor.sensor_standard = n.toFixed(4) + ""
                    saveJsonFile(Common.SENSORS_CONFIG_PATH, sensorsModel)
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
            msg = Common.get_status_info(sm.currentStatus)
        }

        if (!success) {
            msg = "测试失败: " + msg + "! 请重试"
        }

        //        toast.show(msg, 2000)
        return msg
    }

    function getTestData() {
        appendLog("start getTestData id = " + sm.serverJobId)
        sm.send(Common.METHOD_DB_QUERY, {
                    "table": Common.TABLE_EXHALE_TEST,
                    "where_clause": " id =" + sm.serverJobId,
                    "history": true
                }, function (obj) {
                    if (obj.ok) {
                        if (typeof (obj.ok.data) === "object" && obj.ok.data.cal
                                && obj.ok.data.pid) {
                            var serverData = obj.ok.data
                            try {
                                resultPbb = getHistoryResult(serverData.cal.sno.history[0])
                            } catch (e) {
                                console.log("get_test_data error..." + e)
                            }
                        } else {
                            console.log("获取成功, 但格式异常, 重试!")
                            getTestData()
                            return
                        }
                        finish()
                    } else {
                        console.log("serverJobId = " + sm.serverJobId
                                    + " 同步测试数据失败 obj = " + JSON.stringify(
                                        obj.ok))
                        retryTimes += 1
                        if (retryTimes < 5) {
                            setTimeout(function () {
                                getTestData()
                            }, 500)
                        } else {
                            console.log("同步测试数据超时")
                            finish()
                        }
                    }
                })
    }

    Timer {
        id: chart_timer
        repeat: true
        interval: 100
        onTriggered: () => {
                         var obj = sm.sampleData
                         // 结束
                         if (flow_x > 10 && Common.is_helxa_finish(
                                 sm.currentStatus)) {
                             sm.needSaveCache = false
                             sm.appendLog("测试结束 : " + Common.get_status_info(
                                              sm.currentStatus))
                             chart_timer.stop()
                             finishTimes = 1
                             if (sm.currentStatus === Common.STATUS_END_FINISH) {
                                 setTimeout(function () {
                                     getTestData()
                                 }, 300)
                             } else {
                                 reset_data()
                             }

                             return
                         }

                         // 连接异常后, 主动关闭轮询
                         if (!sm.is_open) {
                             restart()
                             return
                         }

                         if (_start_time === 0) {
                             var update_time = new Date(obj[Common.UPDATE_TIME]).getTime()
                             _start_time = update_time
                             reset_data()
                             finishTimes = 0
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

        if (sm.currentStatus === Common.STATUS_FLOW1) {
            return
        }

        if (sm.currentStatus === Common.STATUS_FLOW2) {
            flow_rt = press_rt
        }

        let average = flow_rt
        flow_x += chart_timer.interval / 1000

        char_view.add(flow_x, average)
    }

    function addUmd1(obj) {
        var trace_umd1 = obj[Common.TRACE_UMD1]
        let average = trace_umd1
        umd1_x += chart_timer.interval / 1000

        if (!Common.is_helxa_finish(sm.currentStatus)) {
            chart_umd1.add(umd1_x, average)
        }
    }

    function start() {
        if (!chart_timer.running) {
            result.text = ""
            char_view.clear()
            chart_umd1.clear()
            chart_timer.start()
            preIndex = appSettings.job_id

            appendLog("start sensorIndex = " + sensorIndex + " preIndex = "
                        + preIndex + " job_id = " + appSettings.job_id)
        }
    }

    Item {
        anchors.fill: parent

        AutoYChartView {
            width: parent.width
            height: easyUI ? 0 : parent.height / 2
            id: char_view
            rightYVisible: false
            legendVisible: false
            titleText: "FLOW_RT (ml/s)"
        }

        AutoYChartView {
            anchors.top: char_view.bottom
            width: parent.width
            height: easyUI ? parent.height : parent.height / 2
            id: chart_umd1
            rightYVisible: false
            legendVisible: false
            titleText: "UMD1 (pbb)"
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
            sm.start_helxa_test("Sno", function (obj) {
                if (obj.error) {
                    console.log("Sno 启动失败， 重启Sno = " + obj.error)
                    setTimeout(function () {
                        startSno()
                    }, 1000)
                }
            })
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
    function isOpen() {
        return sm.is_open
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
        isQc = false
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
        chart_timer.stop()
        reset_data()
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

    function finishCheck() {
        sm.refresh(function () {
            setTimeout(function () {
                if (!Common.is_helxa_finish(sm.currentStatus)) {
                    sm.stop_helxa_test(function (obj) {
                        if (obj.ok) {
                            eventBus.sendMessage(Common.MESSAFE_SLOOP_FINISH)
                        } else {
                            console.log("stop_helxa_test failed = " + obj.error)
                            finishCheck()
                        }
                    })
                } else {
                    eventBus.sendMessage(Common.MESSAFE_SLOOP_FINISH)
                }
            }, 200)
        })
    }

    Timer {
        id: timer
        triggeredOnStart: true
        interval: 1000
        repeat: true
        onTriggered: {
            if (!sm.is_open) {
                return
            }

            if (times === 0) {
                // 开始第一次
                _start_test()
                return
            }
            if (finishTimes > 0) {
                finishTimes += 1
                if (sm.arr_umd1.length > 100 && finishTimes === 5
                        && resultPbb.length === 0) {
                    getTestData()
                }
                if (finishTimes > 10) {
                    console.log("完成等待超时...")
                    finishTimes = 0
                    finish()
                    return
                }
            }

            if (times < appSettings.offline_times + 1) {
                if (!sm.inHelxa && preIndex !== appSettings.job_id) {
                    // 结束后
                    timer.stop()
                    if (times === appSettings.offline_times) {
                        // 次数用完, 结束任务
                        sm.appendLog(appSettings.offline_times + "次循环离线测试完成!")
                        stopLoopTest()
                        finishCheck()
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
                console.log("sm.exhaleStarting = " + sm.exhaleStarting)
                // finish()
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
                    // lines_umd1.clear()
                    chart.clear()
                }
                refreshStatus()
            }
        }
    }
}
