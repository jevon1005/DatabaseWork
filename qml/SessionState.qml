pragma Singleton
import QtQuick 2.15

QtObject {
    property string username: ""
    property string role: ""
    property bool isLoggedIn: false

    function clear() {
        username = ""
        role = ""
        isLoggedIn = false
    }
}
