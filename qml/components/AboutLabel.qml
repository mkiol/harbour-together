import QtQuick 2.0
import Sailfish.Silica 1.0

Label {
    anchors.left: parent.left
    anchors.leftMargin: Theme.horizontalPageMargin
    anchors.right: parent.right
    anchors.rightMargin: Theme.horizontalPageMargin
    horizontalAlignment: Qt.AlignHCenter
    color: Theme.primaryColor
    linkColor: Theme.highlightColor
    font.pixelSize: Theme.fontSizeSmall
    wrapMode: Text.WordWrap
    onLinkActivated: handleLink(link)
}
