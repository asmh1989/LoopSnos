import QtQuick
import QtQuick.Controls

TextField {
    anchors.margins: 4
    id: inputField
    height: parent.height
    font.pointSize: 10
    horizontalAlignment: Qt.AlignHCenter
    verticalAlignment: Qt.AlignVCenter
    selectByMouse: true
    clip: true
}
