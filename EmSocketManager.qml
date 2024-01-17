import QtQuick

import EmSockets

import SysSettings

import "common.js" as Common

Item {
    property alias url: socket.url
    property alias type: socket.type
    property alias interval: timer.interval
    property alias settings: sysSettings

    property alias errorString: socket.errorString

    readonly property string _sample_value: JSON.stringify(
                                                Common.get_sample_req(0))

    property int read_times: 0
    property int update_count: 0
    property var send_time

    property string currentStatus: ""
    property var sampleData

    property bool is_open: false

    property var umdParams

    property string title: ""
    /// 呼吸检测进行状态
    //业务层状态
    property bool inHelxa: false
    //服务端状态
    property bool exhaleStarting: false

    signal connectReceived(string message)
    signal settingChanged
    SysSettings {
        id: sysSettings
    }

    EmSocket {
        id: socket
        type: EmSocket.WebSocket
        onTextMessageReceived: function (message) {
            if (stackView.currentItem
                    && stackView.currentItem.title !== title) {
                return
            }

            //            console.log("耗时: " + (new Date().getTime(
            //                                      ) - send_time) + " " + message)
            var obj = JSON.parse(message)
            if (obj.method === "test") {
                socket.notifyTestOk()
                return
            } else if (obj.method === Common.METHOD_HELXA_STARTED) {
                if (inHelxa) {
                    appendLog("recv server command to start")
                    timer.restart()
                    exhaleStarting = true
                }
                return
            } else if (obj.method === Common.METHOD_HELXA_STARTING) {
                appendLog("设备正在启动中")
                exhaleStarting = false
                return
            } else if (obj.method === Common.METHOD_DEVICE_HELXA_FAILED) {
                appendLog("设备启动异常, 请重试")
                inHelxa = false
                exhaleStarting = false
                return
            }

            if (obj.ok) {
                if (obj.method === Common.METHOD_GET_SAMPLE) {
                    if (sampleData
                            && sampleData["update_time"] !== obj.ok["update_time"]) {
                        update_count += 1
                    }
                    sampleData = obj.ok

                    currentStatus = sampleData[Common.FUNC_STATUS]

                    if (inHelxa && update_count > 10 && Common.is_helxa_finish(
                                currentStatus)) {
                        inHelxa = false
                    }
                } else if (obj.method === Common.METHOD_START_HELXA
                           && socket.type === EmSocket.WebSocket) {
                    if (!inHelxa) {
                        start_helxa_test("")
                    }
                } else if (obj.method === Common.METHOD_DB_QUERY) {
                    switch (obj.ok.table) {
                    case Common.TABLE_DEVICE_INFO:
                    {
                        break
                    }
                    case Common.TABLE_SYS_SETTINGS:
                    {
                        sysSettings.loadFromJson(obj.ok.data)
                        settingChanged()
                        break
                    }
                    }
                } else if (obj.method === Common.METHOD_READ_UMD_PARAMS) {
                    umdParams = obj.ok
                }
            } else {
                showToast("error msg =  " + message)
            }
        }

        onStatusChanged: {
            if (socket.url.toString().length < 10) {
                return
            }
            if (socket.status == EmSocket.Error) {
                if (socket.errorString.length > 0) {
                    appendLog("Error: " + socket.errorString)
                    connectReceived("Error: " + socket.errorString)
                }
                is_open = false
            } else if (socket.status == EmSocket.Open) {
                appendLog("connected ")
                connectReceived("Socket connected ")

                is_open = true
                if (!sampleData) {
                    getSysSettings()
                    getUmdParams()
                    refresh()
                }
            } else if (socket.status == EmSocket.Closed) {
                appendLog("closed")
                connectReceived("Socket closed")

                is_open = false
            } else if (socket.status == EmSocket.Connecting) {
                appendLog("Socket Connecting")
                connectReceived("Connecting")
            }
            if (!is_open) {
                helxa_reset()
            }
        }

        active: true
    }

    /// 定时获取sample数据
    Timer {
        id: timer
        repeat: true
        interval: 100
        onTriggered: () => {
                         if (!inHelxa) {
                             helxa_reset()
                             return
                         }

                         read_times += 1
                         _send_(_sample_value)
                     }
    }

    function sendJson(msg) {
        if (is_open) {
            _send_(JSON.stringify(msg))
        } else {
            toast.show("websockets 已断开", 3000)
            helxa_reset()
        }
    }

    function _send_(msg) {
        send_time = new Date().getTime()
        socket.sendTextMessage(msg)
    }

    /// 呼吸检测重置
    function helxa_reset() {
        if (read_times > 50) {
            appendLog("helxa_stop: read_times = " + read_times + " update_count = " + update_count)
        }

        read_times = 0
        update_count = 0
        timer.stop()
        inHelxa = false
        exhaleStarting = false
    }

    function start_helxa_test(command) {
        if (!timer.running) {
            if (command.length !== 0) {
                var msg = Common.get_start_helxa_req(command)
                appendLog("send: " + JSON.stringify(msg))
                sendJson(msg)
            }
            helxa_reset()
            inHelxa = true
            console.log("start_helxa_test ...")
        } else {
            console.log("已在呼吸测试中, 请稍后")
        }
    }

    function stop_helxa_test() {
        var msg = Common.get_stop_helxa_req()
        appendLog("send: " + JSON.stringify(msg))
        sendJson(msg)
        helxa_reset()
        refresh_timer.start()
    }

    function refresh() {
        let msg = Common.get_sample_req(30)
        sendJson(msg)
    }

    function appendLog(msg) {
        // console.log(socket.url + " => " + msg)
        eventBus.sendMessage(Common.MESSAGE_ADD_LOG, socket.url + "=>" + msg)
    }

    function open() {
        socket.open()
    }

    function close() {
        socket.close()
    }

    function getSysSettings() {
        sendJson({
                     "method": Common.METHOD_DB_QUERY,
                     "args": {
                         "table": Common.TABLE_SYS_SETTINGS,
                         "where_clause": " id >0"
                     }
                 })
    }

    function getUmdParams() {
        sendJson({
                     "method": Common.METHOD_READ_UMD_PARAMS
                 })
    }

    Component.onCompleted: {

        //        socket.open()
    }

    Component.onDestruction: {
        socket.close()
        timer.stop()
    }
}
