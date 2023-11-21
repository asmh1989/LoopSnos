
//pragma Singleton
import QtQuick

QtObject {
    id: eventBus
    signal messageReceived(string message, var data)

    function sendMessage(message, data) {
        messageReceived(message, data)
    }
}
