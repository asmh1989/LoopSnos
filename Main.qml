import QtQuick
import QtQuick.Window
import QtQuick.Controls

import "common.js" as Common

import Qt.labs.settings 1.0
import QtQuick.Controls.Material
import FileIO
import EmSockets

ApplicationWindow {
    id: window
    width: appSettings.width > 0 ? appSettings.width : 1200
    height: 800
    minimumHeight: 800
    minimumWidth: 1200
    visible: true
    x: appSettings.x > 0 ? appSettings.x : 100
    y: appSettings.y > 0 ? appSettings.y : 100
    title: qsTr("LoopSnos")

    //    Material.theme: Material.Dark
    Material.primary: Material.Blue
    Material.accent: Material.Blue

    property var preTestDate

    property var sensorsModel: []
    property var airBagsModel: []
    property var loopModel: []

    property bool isQc: false
    property string _time_name: ""

    property int humidity: appSettings.indoor_humi
    property real temperature: appSettings.indoor_temp

    Action {
        id: navigateBackAction
        icon.source: "/img/back.png"
        onTriggered: {
            pop()
        }
    }

    ToastManager {
        id: toast
    }

    EventBus {
        id: eventBus
    }

    FileIO {
        id: file
    }

    function getResultPrefix() {
        return "record_sno/" + _time_name
    }

    function loadJsonFile(source) {
        file.source = source
        var d = file.read()
        try {
            return JSON.parse(d)
        } catch (e) {
            return []
        }
    }
    function getGasConc() {
        return parseInt(airBagsModel[appSettings.val_index].gas_conc)
    }

    function saveJsonFile(source, data, no) {
        file.source = source
        file.write(JSON.stringify(data))
        console.log("save = " + JSON.stringify(data))
        if (!no) {
            showToast("保存成功： " + source)
        }
        eventBus.sendMessage(Common.MESSAGE_REFRESH_CONFIG)
        if (!no) {
            pop()
        }
    }

    Flickable {
        width: parent.width
        height: parent.height
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds

        ScrollIndicator.vertical: ScrollIndicator {}

        StackView {
            id: stackView
            anchors.fill: parent
            initialItem: HomePage {}
        }

        Component {
            id: dataAnalysisPage
            DataAnalysisPage {}
        }

        Component {
            id: curveAnalysisPage
            CurveAnalysisPage {}
        }

        Component {
            id: loopPage
            LoopPage {}
        }
    }
    function pop() {
        stackView.pop()
    }

    function openSensorsPage() {
        stackView.push("SensorsPage.qml")
    }
    function openAirBagPage() {
        stackView.push("AirBagPage.qml")
    }
    function openDataAnalysisPage() {
        stackView.push(dataAnalysisPage)
    }

    function showToast(msg, time) {
        toast.show(msg, time ? time : 1500)
    }

    function setTimeout(func, interval, ...params) {
        return setTimeoutComponent.createObject(window, {
                                                    "func": func,
                                                    "interval": interval,
                                                    "params": params
                                                })
    }

    function clearTimeout(timerObj) {
        timerObj.stop()
        timerObj.destroy()
    }

    Component.onCompleted: {
        airBagsModel = loadJsonFile(Common.AIRBAG_CONFIG_PATH)
        if (airBagsModel.length == 0) {
            [1, 2, 3, 4, 5, 6, 7, 8].forEach(function (e) {
                airBagsModel.push(JSON.parse(JSON.stringify(
                                                 Common.JSON_AIRBAG)))
            })
        }

        sensorsModel = loadJsonFile(Common.SENSORS_CONFIG_PATH)
        if (sensorsModel.length == 0) {
            [1, 2, 3, 4].forEach(function (e) {
                sensorsModel.push(JSON.parse(JSON.stringify(
                                                 Common.JSON_SENSOR)))
            })
        }

        loopModel = loadJsonFile(Common.LOOP_CONFIG_PATH)
        loopModel = loopModel.map(v => Object.assign({
                                                         "waiting": 0
                                                     }, v))

        webSocket.open()

        var now = new Date()
        var year = now.getFullYear()
        var month = String(now.getMonth() + 1).padStart(2, '0')
        var day = String(now.getDate()).padStart(2, '0')
        _time_name = year + month + day
    }

    Component.onDestruction: {
        appSettings.width = window.width
        appSettings.x = window.x
        appSettings.y = window.y
    }

    Database {
        id: db
    }

    Component {
        id: setTimeoutComponent
        Timer {
            property var func
            property var params
            running: true
            repeat: false
            onTriggered: {
                func(...params)
                destroy()
            }
        }
    }

    function openVal() {

        if (webSocket.status === EmSocket.Open) {
            eventBus.sendMessage(Common.MESSAGE_ADD_LOG,
                                 "打开阀门 = " + (appSettings.val_index + 1))
            webSocket.sendTextMessage(JSON.stringify({
                                                         "method": "valve",
                                                         "args": [appSettings.val_index + 1]
                                                     }))
            setTimeout(() => refreshVal(), 200)
        } else {
            webSocket.open()
            eventBus.sendMessage(Common.MESSAGE_ADD_LOG, "阀门服务连接失败")
        }
    }

    function refreshVal() {
        if (webSocket.status === EmSocket.Open) {
            webSocket.sendTextMessage(JSON.stringify({
                                                         "method": "state"
                                                     }))
        } else {
            webSocket.open()
        }
    }

    function appendLog(msg) {
        eventBus.sendMessage(Common.MESSAGE_ADD_LOG, msg)
    }

    EmSocket {
        id: webSocket
        url: appSettings.val_url
        type: EmSocket.WebSocket
        onTextMessageReceived: function (message) {
            console.log("阀门服务端 recv = " + message)

            var obj = JSON.parse(message)
            if (obj.temperature) {
                temperature = parseFloat(obj.temperature.toFixed(1))
            }
            if (obj.humidity) {
                humidity = obj.humidity
            }
        }
        onStatusChanged: {
            if (webSocket.status === EmSocket.Error) {
                console.log("阀门服务端 error = " + webSocket.errorString)
            } else if (webSocket.status === EmSocket.Open) {
                console.log("阀门服务端 Connected ")
                refreshVal()
            } else if (webSocket.status === EmSocket.Closed) {
                console.log("阀门服务端 Closed ")
            } else if (webSocket.status === EmSocket.Connecting) {
                console.log("阀门服务端 Connecting ")
            }
        }

        active: true
    }

    function calValue(arr, td, sensor_standard) {
        var av1 = Common.mean(arr.slice(appSettings.umd_state1,
                                        appSettings.umd_state2))

        var av2 = Common.mean(arr.slice(appSettings.umd_state3,
                                        appSettings.umd_state4))
        var r = Math.abs(av1 - av2).toFixed(2)
        var fix_r = fix_umd(td, r)
        return fix_umd2(fix_r, sensor_standard)
    }

    function fix_umd(trace_umd1_temp, umd1) {
        var x = trace_umd1_temp - appSettings.umd_standard_temp
        var fix_xs = appSettings.standard_arg1 * x * x * x + appSettings.standard_arg2 * x
                * x + appSettings.standard_arg3 * x + appSettings.standard_arg4

        return (fix_xs * umd1).toFixed(2)
    }

    function fix_umd2(umd1, sensor_standard) {
        return (umd1 / sensor_standard).toFixed(1)
    }

    Settings {
        id: appSettings
        fileName: "./config.txt"
        property int job_id: 1
        property int umd_state1: 200
        property int umd_state2: 250
        property int umd_state3: 650
        property int umd_state4: 700

        property int offline_times: 10
        property int offline_interval: 2

        property int width: 0

        property int x: 0
        property int y: 0

        // property real umd_standard: 3.8612
        property real umd_standard_temp: 26.7
        property real standard_arg1: 0.00004
        property real standard_arg2: 0.0009
        property real standard_arg3: -0.0126
        property real standard_arg4: 1
        // 阀门序号
        property int val_index: 0
        property real indoor_temp: 25
        property int indoor_humi: 48

        property string val_url: "ws://192.168.2.89:5533"
    }
}
