import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Dialogs

import "common.js" as Common

Page {
    id: page
    title: "loop"
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

                onClicked: {
                    stop()
                }
            }

            Label {
                id: titleLabel
                text: "高级循环测试"
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

    EventBus {
        id: bus
    }

    property int curIndex: 0
    property int curFmIndex: 0
    property int curFm: 0

    property bool running: false

    property var urls: []

    property int waiting: 0

    property int changeTime: 0

    function start() {
        if (loopModel.length === 0) {
            showToast("请先添加任务")
            return
        }

        area.clear()
        running = true
        cacheData = []
        curIndex = 0
        curFmIndex = 0
        realStart()
        timer.start()
        changeTime = 0
    }

    function realStart() {
        mlog("realStart ..")
        eventBus.sendMessage(
                    Common.MESSAGE_ADD_LOG,
                    "高级离线循环测试 curIndex = " + curIndex + " curFmIndex = " + curFmIndex)
        var m = loopModel[curIndex]
        var dd = Common.generateArrayFromString(m.fm)
        openFm(dd[curFmIndex])
        appSettings.offline_interval = m.delay
        appSettings.offline_times = m.count
        cacheData = urls.map(v => m.count)
        bus.sendMessage("StartLoopTest")
    }

    function openFm(i) {
        curFm = i
        appSettings.val_index = i - 1
        openVal()
    }

    function stop() {
        waiting = 0
        running = false
        if (curIndex + 1 === loopModel.length) {
            cacheData = ["完成"]
        } else {
            cacheData = ["终止"]
        }

        // curIndex = 0
        // curFmIndex = 0
        bus.sendMessage("StopLoopTest")
        timer.stop()
        eventBus.sendMessage(Common.MESSAGE_ADD_LOG, "高级离线循环测试完成")
        refresh()
    }

    function refresh() {
        ww.visible = waiting > 0
        if (waiting > 0) {
            ww.text = "等待中 ... " + waiting
            waiting -= 1
            if (waiting === 0) {
                setTimeout(function () {
                    realStart()
                }, 1000)
            }
        } else {
            ttIndex.text = curIndex + 1
            ttFm.text = curFm
            ttStatus.text = cacheData.join(",")
        }
    }

    function loadConfig() {
        fileDialog.open()
    }

    function toModelData(dd) {
        var r = []
        for (const d of dd) {
            for (var i = 0; i < d.loop; i++) {
                r = r.concat(d.data)
            }
        }
        return r
    }

    FileDialog {
        id: fileDialog
        nameFilters: ["json file (*.json)"]

        onAccepted: {
            var path = (fileDialog.currentFile + "").replace("file:///", "")
            file.source = path
            var content = file.read()
            mlog("path = " + path)
            mlog("read content = " + content)
            var arr = Common.validateJson(content)
            if (arr.length === 0) {
                showToast("解析失败, 请检查文件内容: " + path)
            } else {
                loopModel = toModelData(arr)
                showToast("导入成功, 共发现 " + loopModel.length + " 条任务")
                setTimeout(function () {
                    saveJsonFile(Common.LOOP_CONFIG_PATH, loopModel, true)
                }, 100)
                listView.model = loopModel
            }
        }
    }
    // padding: 20
    Column {
        anchors.fill: parent
        Row {
            width: parent.width
            height: parent.height * 0.35
            Item {
                width: parent.width * 0.03
                height: 1
            }

            Column {
                height: parent.height
                width: parent.width * 0.42
                spacing: 4
                Item {
                    width: 10
                    height: 6
                }

                Row {
                    id: addRow
                    height: 30
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }

                    spacing: 4
                    Text {
                        text: "阀门顺序: "
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    TextField {
                        id: tf1
                        height: parent.height
                        width: parent.height * 2.5
                        validator: RegularExpressionValidator {
                            regularExpression: /^[0-9]+(-[0-9]+)?(,[0-9]+(-[0-9]+)?)*$/
                        }

                        onTextChanged: {

                            // mlog("ids = " + Common.generateArrayFromString(
                            //                 text))
                        }
                    }

                    Text {
                        text: "循环次数: "
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    TextField {
                        id: tf2
                        height: parent.height
                        width: parent.height * 1.5
                        validator: IntValidator {
                            bottom: 1
                            top: 100
                        }
                    }

                    Text {
                        text: "间隔(S): "
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    TextField {
                        id: tf3
                        height: parent.height
                        width: parent.height * 1.5
                        validator: IntValidator {
                            bottom: 1
                            top: 100
                        }
                    }
                    Text {
                        text: "完成等待(S):"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: tf4
                        height: parent.height
                        width: parent.height * 2
                        text: 0 + ""
                        validator: IntValidator {
                            bottom: 0
                            top: 100000
                        }
                    }

                    Button {
                        height: parent.height * 1.2
                        text: "新增"
                        anchors.verticalCenter: parent.verticalCenter

                        onClicked: {
                            if (tf1.text.length === 0 || tf2.text.length === 0
                                    || tf3.text.length === 0) {
                                showToast("请输入完整")
                                return
                            }

                            var d = Common.generateArrayFromString(
                                        tf1.text).filter(v => v < 9)
                            var fms = Common.convertToRangeString(d)
                            tf1.text = fms

                            var count = parseInt(tf2.text)
                            var delay = parseInt(tf3.text)
                            var waiting = parseInt(tf4.text)

                            loopModel.push({
                                               "fm": fms,
                                               "count": count,
                                               "delay": delay,
                                               "waiting": waiting
                                           })

                            saveJsonFile(Common.LOOP_CONFIG_PATH,
                                         loopModel, true)
                            listView.model = loopModel
                        }
                    }
                }

                Rectangle {
                    height: parent.height - addRow.height - 16
                    width: parent.width
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                    border {
                        width: 1
                        color: 'lightGray'
                    }
                    ListView {
                        id: listView
                        anchors.fill: parent
                        boundsBehavior: Flickable.StopAtBounds
                        boundsMovement: Flickable.StopAtBounds
                        clip: true
                        headerPositioning: ListView.OverlayHeader
                        ScrollBar.vertical: ScrollBar {}
                        header: Rectangle {
                            color: Material.primary
                            height: 30
                            width: listView.width
                            z: 100

                            Row {
                                anchors.fill: parent
                                Item {
                                    width: parent.width / 6
                                    height: parent.height

                                    Text {
                                        text: "序号"
                                        color: 'white'
                                        anchors.centerIn: parent
                                    }
                                }

                                Item {
                                    width: parent.width / 6
                                    height: parent.height

                                    Text {
                                        text: "阀门顺序"
                                        color: 'white'

                                        anchors.centerIn: parent
                                    }
                                }

                                Item {
                                    width: parent.width / 6
                                    height: parent.height

                                    Text {
                                        text: "循环次数"
                                        color: 'white'

                                        anchors.centerIn: parent
                                    }
                                }
                                Item {
                                    width: parent.width / 6
                                    height: parent.height

                                    Text {
                                        text: "间隔时间"
                                        color: 'white'

                                        anchors.centerIn: parent
                                    }
                                }

                                Item {
                                    width: parent.width / 6
                                    height: parent.height

                                    Text {
                                        text: "完成等待"
                                        color: 'white'

                                        anchors.centerIn: parent
                                    }
                                }
                                Item {
                                    width: parent.width / 6
                                    height: parent.height

                                    Text {
                                        text: "操作"
                                        color: 'white'

                                        anchors.centerIn: parent
                                    }
                                }
                            }
                        }
                        model: loopModel
                        delegate: Item {
                            height: 30
                            width: listView.width

                            Row {
                                anchors.fill: parent
                                Item {
                                    width: parent.width / 6
                                    height: parent.height

                                    Text {
                                        text: (index + 1) + ""
                                        anchors.centerIn: parent
                                    }
                                }

                                Item {
                                    width: parent.width / 6
                                    height: parent.height

                                    Text {
                                        text: modelData.fm + ""
                                        anchors.centerIn: parent
                                    }
                                }

                                Item {
                                    width: parent.width / 6
                                    height: parent.height

                                    Text {
                                        text: modelData.count + ""
                                        anchors.centerIn: parent
                                    }
                                }
                                Item {
                                    width: parent.width / 6
                                    height: parent.height

                                    Text {
                                        text: modelData.delay + ""
                                        anchors.centerIn: parent
                                    }
                                }

                                Item {
                                    width: parent.width / 6
                                    height: parent.height

                                    Text {
                                        text: modelData.waiting + ""
                                        anchors.centerIn: parent
                                    }
                                }

                                Item {
                                    width: parent.width / 6
                                    height: parent.height

                                    Button {
                                        text: "删除"
                                        height: parent.height
                                        anchors.centerIn: parent

                                        onClicked: {
                                            loopModel.splice(index, 1)
                                            saveJsonFile(Common.LOOP_CONFIG_PATH,
                                                         loopModel, true)
                                            listView.model = loopModel
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                width: parent.width * 0.1
                height: parent.height

                Column {
                    anchors.centerIn: parent

                    Button {
                        text: "导入"
                        enabled: !running
                        onClicked: {
                            loadConfig()
                        }
                    }

                    Button {
                        text: "开始"
                        enabled: !running
                        onClicked: {
                            start()
                        }
                    }

                    Button {
                        text: "停止"
                        enabled: running

                        onClicked: {
                            appendLog("强制停止")
                            stop()
                        }
                    }

                    Button {
                        text: "清除"

                        onClicked: {
                            area.clear()
                        }
                    }
                }
            }

            ScrollView {
                id: scroll
                width: parent.width * 0.42
                height: parent.height

                TextArea {
                    id: area
                    wrapMode: Text.Wrap
                    font.pointSize: 8
                    font.family: "Consolas"
                    selectByMouse: true
                }
            }
        }

        Row {
            height: 60
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            visible: true
            Item {
                width: 60
                height: 60
                visible: running
                BusyIndicator {
                    anchors.centerIn: parent
                    running: running
                }
            }

            Text {
                text: "工作序号:"
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: ttIndex
                text: curIndex + ""
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "当前阀门:"
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: ttFm
                text: curFm + ""
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "状态:"
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: ttStatus
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: ww
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: parent.width
            height: parent.height * 0.55

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
                    myurl: urls[index]
                    easyUI: true
                    title: page.title
                    border {
                        width: 4
                        color: 'lightGray'
                    }
                    anchors.margins: 2

                    Connections {
                        target: bus

                        function onMessageReceived(message, content) {
                            if (message === "StartLoopTest") {
                                if (!sno.isOpen()) {
                                    sno.open()
                                    setTimeout(function () {
                                        sno.startLoopTest()
                                    }, 100)
                                } else {
                                    sno.startLoopTest()
                                }
                            } else if (message === "StopLoopTest") {
                                sno.stopLoopTest()
                            } else if (message === "CheckConnection") {
                                if (!sno.isOpen()) {
                                    sno.open()
                                }
                            } else if (message === "Restart") {
                                sno.close()
                                sno.restart()
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: timer
        triggeredOnStart: true
        repeat: true
        interval: 1000
        onTriggered: {
            refresh()
            if (waiting < 2) {
                changeTime += 1
            }

            if (changeTime > 120) {
                if (changeTime === 121 || changeTime % 7200 === 0) {
                    postWechat()
                    bus.sendMessage("Restart")
                }
            } else if (changeTime > 80 && changeTime % 10 === 0) {
                mlog("长时间没反应, 主动检查完成情况, curIndex = " + curIndex + " curFmIndex = "
                     + curFmIndex + " changeTime = " + changeTime + " waiting = "
                     + waiting + " cacheData = " + JSON.stringify(cacheData))
                cacheData = [0]
                loopFinishCheck()
            }

            if (changeTime % 2 === 0) {
                bus.sendMessage("CheckConnection")
            }
        }
    }

    function appendLog(msg) {
        mlog(msg)
        if (msg.length === 0) {
            area.text = ""
        } else {
            var d = Common.formatDate3(new Date())
            area.text += d
            area.text += msg
            area.text += "\n"
            area.cursorPosition = area.length - 1
        }
    }

    function loopFinishCheck() {
        if (!running) {
            mlog("loopFinishCheck already stop")
            return
        }

        var has = cacheData.filter(v => v !== 0)
        console.log("cacheData = " + JSON.stringify(cacheData))
        if (has.length === 0) {
            var m = loopModel[curIndex]
            var dd = Common.generateArrayFromString(m.fm)
            if (curFmIndex + 1 === dd.length) {
                if (curIndex + 1 === loopModel.length) {
                    stop()
                    return
                } else {
                    appendLog("序列号 = " + curIndex + " 已完成")
                    waiting = m.waiting

                    curIndex += 1
                    curFmIndex = 0
                }
            } else {
                curFmIndex += 1
                appendLog("curIndex = " + curIndex + " curFmIndex = " + curFmIndex)
            }
            if (waiting === 0) {
                setTimeout(function () {
                    realStart()
                }, 1500)
            } else {
                appendLog("开始完成等待...")
            }
        }
    }

    Connections {
        target: eventBus

        function onMessageReceived(msg, data) {
            changeTime = 0

            if (msg === Common.MESSAGE_ADD_LOG) {
                appendLog(data)
            } else if (msg === Common.MESSAGE_FINISH_ONE) {

                // if (cacheData[data] > 0) {
                //     cacheData[data] -= 1
                // }
            } else if (msg === Common.MESSAGE_SOCKET_CONNECT) {
                if (!data.connected) {
                    cacheData[data.index] = 0
                }
            } else if (msg === Common.MESSAFE_SLOOP_FINISH) {
                loopFinishCheck()
            }
        }
    }

    Component.onCompleted: {

        sensorsModel.forEach(function (element) {
            urls.push(Common.fix_url(element.addr))
        })
        grid.model = urls
    }
}
