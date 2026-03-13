import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Window {
    id: timetableWin
    width: 400; height: 360
    minimumWidth: 400; minimumHeight: 360;
    maximumWidth: 1920; maximumHeight: 1440
    visible: true
    color: "#ffffff"

    signal closed()
    property var timetable: []

    onClosing: {
        closed()
    }

    TimetableView{
        width: parent.width
        height: parent.height
        showButtons: false
        passingStationList: timetable
    }
}
