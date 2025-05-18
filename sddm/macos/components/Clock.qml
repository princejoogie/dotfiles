import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    spacing: 2

        FontLoader {
        id: fontbold
        source: "../fonts/SFUIText-Semibold.otf"
    }
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software
    Label {
        text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
        color: "white"
        opacity: 0.5
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? ColorScope.backgroundColor : "transparent" //no outline, doesn't matter
        font.pointSize: 20
        font.weight: Font.DemiBold
        font.capitalization: Font.Capitalize
        Layout.alignment: Qt.AlignHCenter
        font.family: fontbold.name

    }
    Label {
        text: Qt.formatDateTime(new Date(), "h:mm")
        color: "white"
        opacity: 0.5
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? ColorScope.backgroundColor : "transparent" //no outline, doesn't matter
        font.pointSize: 100
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
        font.family: fontbold.name

    }
}
