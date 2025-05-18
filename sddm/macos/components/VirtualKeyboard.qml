import QtQuick
import QtQuick.VirtualKeyboard 2.15
import QtQuick.VirtualKeyboard.Styles 2.15
import QtQuick.VirtualKeyboard.Settings 2.15

InputPanel {
    id: inputPanel
    property bool activated: false
    active: activated && Qt.inputMethod.visible
    visible: active
    width: parent.width
}
