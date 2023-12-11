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
                text: "循环测试"
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


    Component.onCompleted: {

    }
}
