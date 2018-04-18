import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    property int padding: 0

    color: "transparent"
    height: content.height + (2 * padding)

    Row {
        id: content
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.paddingMedium

        IconButton {
            icon.source: "image://theme/icon-s-message?" + (mouse.pressed ? Theme.highlightColor : Theme.primaryColor)
            height: parent.height
            width: Theme.iconSizeSmall
        }

        Label {
            text: qsTr("add a comment")
            color: mouse.pressed ? Theme.secondaryHighlightColor : Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            width: parent.width
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
    }
}
