import QtQuick

QtObject {
    readonly property string capslockWarning:   qsTr("Warning, Caps Lock is ON!")
    readonly property string layout:            qsTr("Layout")
    readonly property string login:             qsTr("Login")
    readonly property string loginFailed:       qsTr("Login failed")
    readonly property string loginSucceeded:    qsTr("Login succeeded")
    readonly property string password:          qsTr("Password")
    readonly property string emptyPassword:     qsTr("Please enter a password!")
    readonly property string passwordChange:    qsTr("Change password")
    readonly property string prompt:            qsTr("Enter your username and password")
    readonly property string promptSelectUser:  qsTr("Select your user and enter password")
    readonly property string promptUser:        qsTr("Enter your username")
    readonly property string promptPassword:    qsTr("Enter your password")
    readonly property string emptyPrompt:       qsTr("Password:")
    readonly property string showPasswordPrompt:qsTr("Show password")
    readonly property string hidePasswordPrompt:qsTr("Hide password")
    readonly property string reboot:            qsTr("Reboot")
    readonly property string session:           qsTr("Session")
    readonly property string shutdown:          qsTr("Shutdown")
    readonly property string suspend:           qsTr("Suspend")
    readonly property string hibernate:         qsTr("Hibernate")
    readonly property string userName:          qsTr("Username")
    readonly property string welcomeText:       qsTr("Welcome to %1")
    readonly property string pamMaxtriesError:  qsTr("Password change aborted because maximum tries reached")
    readonly property string pamMaxtriesInfo:   qsTr("New password change round! Please input current password again!")
}

