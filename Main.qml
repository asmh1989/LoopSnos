import QtQuick
import QtQuick.Window
import QtQuick.Controls

import "common.js" as Common

import Qt.labs.settings 1.0

ApplicationWindow {
    id: window
    width: appSettings.width > 0 ? appSettings.width : 1024
    height: 800
    minimumHeight: 800
    minimumWidth: 1024
    visible: true
    title: qsTr("LoopSnos")

    ToastManager {
        id: toast
    }

    EventBus {
        id: eventBus
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

    Component.onDestruction: {
        appSettings.width = window.width
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
        property int umd_state1: 201
        property int umd_state2: 250
        property int umd_state3: 451
        property int umd_state4: 500

        property int offline_times: 10
        property int offline_interval: 2

        property int width: 0

        property real umd_standard: 3.8612
        property real umd_standard_temp: 26.7
        property real standard_arg1: 0.00004
        property real standard_arg2: 0.0009
        property real standard_arg3: -0.0126
        property real standard_arg4: 1
    }
}
