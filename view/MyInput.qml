import QtQuick
import QtQuick.Controls

Rectangle {
    property alias myInput: inputField.text
    property alias enabled: inputField.enabled
    height: parent.height

    //    border.color: '#50A0FF'
    //    border.width: 1
    //    radius: 4
    TextField {
        anchors.margins: 4
        id: inputField
        anchors.fill: parent
        //        anchors.margins: 2
        font.pointSize: 10
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        selectByMouse: true
        clip: true
    }
}
