import QtQuick

Item {
    property alias usersList: usersList
    property string lastNameUser: userModel.lastUser
    property string finalLoginUserName
    property url lastUrlAvatar

    property bool fullChargeModel: customUserModel.count === userModel.count

    function updateOrdenModel(name){

        if (fullChargeModel) {

            var index
            for (var a = 0; a < customUserModel.count; a++){
                if (customUserModel.get(a).name === name) {
                    index = a
                    lastUrlAvatar = customUserModel.get(a).icon
                }
            }

            usersList.clear()

            for (var u = index; u <  (index + customUserModel.count); u++) {
                var newIndex = u % (customUserModel.count)
                usersList.append({ name: customUserModel.get(newIndex).name, icon: customUserModel.get(newIndex).icon, });
            }
        }
    }
    Repeater {
        model: userModel
        delegate: Item {
            Component.onCompleted: {
                customUserModel.append({ name: model.name, icon: model.icon });
                if(model.lastUser) {
                    lastNameUser = model.lastUser
                }
            }
        }
    }

    onLastNameUserChanged: {
        finalLoginUserName = lastNameUser || customUserModel.get(0).name
        updateOrdenModel(lastNameUser || customUserModel.get(0).name)
    }

    onFullChargeModelChanged: {

        updateOrdenModel(lastNameUser || customUserModel.get(0).name)
    }

    ListModel {
        id: customUserModel
    }

    ListModel {
        id: usersList
    }
    Component.onCompleted: {
        finalLoginUserName = lastNameUser || customUserModel.get(0).name
    }
}
