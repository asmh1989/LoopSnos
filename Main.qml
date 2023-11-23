import QtQuick
import QtQuick.Window
import QtQuick.Controls

import "common.js" as Common

import Qt.labs.settings 1.0
import QtQuick.Controls.Material
import FileIO

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

    property var sensorsModel: []
    property var airBagsModel: []

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

    function loadJsonFile(source) {
        file.source = source
        var d = file.read()
        try {
            return JSON.parse(d)
        } catch (e) {
            return []
        }
    }

    function saveJsonFile(source, data) {
        file.source = source
        file.write(JSON.stringify(data))
        showToast("保存成功： " + source)
        eventBus.sendMessage(Common.MESSAGE_REFRESH_CONFIG)
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

        //        Keys.onPressed: function (event) {
        //            if (event.key === Qt.Key_Tab) {
        //                event.accepted = false // 禁用默认的Tab键行为

        //                // 获取当前具有焦点的TextField
        //                var currentTextField = Qt.inputMethod.focusObject

        //                // 获取所有的TextField
        //                var textFields = parent.children.filter(function (child) {
        //                    return child instanceof TextInput
        //                })

        //                // 获取当前TextField在数组中的索引
        //                var currentIndex = textFields.indexOf(currentTextField)

        //                // 计算下一个TextField的索引
        //                var nextIndex = (currentIndex + 1) % textFields.length

        //                // 将焦点设置为下一个TextField
        //                textFields[nextIndex].forceActiveFocus()
        //            }
        //        }
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

    function showToast(msg) {
        toast.show(msg, 3000)
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
                airBagsModel.push(Common.JSON_SENSOR)
            })
        }

        sensorsModel = loadJsonFile(Common.SENSORS_CONFIG_PATH)
        if (sensorsModel.length == 0) {
            [1, 2, 3, 4].forEach(function (e) {
                airBagsModel.push(Common.JSON_AIRBAG)
            })
        }
    }

    Component.onDestruction: {
        appSettings.width = window.width
        appSettings.x = window.x
        appSettings.y = window.y
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

    Settings {
        id: appSettings
        fileName: "./config.txt"
        property int umd_state1: 200
        property int umd_state2: 250
        property int umd_state3: 650
        property int umd_state4: 700

        property int offline_times: 10
        property int offline_interval: 2

        property int width: 0

        property int x: 0
        property int y: 0

        property real umd_standard: 3.8612
        property real umd_standard_temp: 26.7
        property real standard_arg1: 0.00004
        property real standard_arg2: 0.0009
        property real standard_arg3: -0.0126
        property real standard_arg4: 1
        // 阀门序号
        property int val_index: 1
        property real indoor_umd: 25
        property int indoor_humi: 48
    }
}
