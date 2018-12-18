import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/utils.js" as Utils

Page {
    property variant question: ({})

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.rightMargin: Theme.horizontalPageMargin

            PageHeader {
                title: question.title
            }

            SectionHeader {
                text: qsTr("Question tools")
                x: 0
                visible: typeof question.followers !== "undefined"
            }

            Label {
                text: typeof question.followers !== "undefined" ? question.followers : ""
                width: parent.width
                wrapMode: Text.WordWrap
            }

            SectionHeader {
                text: qsTr("Public thread")
                x: 0
            }

            Label {
                text: "This thread is public, all members of Together.Jolla.Com can read this page."
                width: parent.width
                wrapMode: Text.WordWrap
            }

            SectionHeader {
                text: qsTr("Stats")
                x: 0
            }

            QuestionStat {
                label: qsTr("Asked")
                value: question.added_at_label
                width: parent.width
            }

            QuestionStat {
                label: qsTr("Seen")
                value: qsTr("%1 times").arg(question.view_count)
                width: parent.width
            }

            QuestionStat {
                label: qsTr("Last updated")
                value: question.last_activity_label
                width: parent.width
            }

            SectionHeader {
                text: qsTr("Related questions")
                x: 0
                visible: listView.count
            }

            ListView {
                id: listView
                width: parent.width + 2 * Theme.horizontalPageMargin
                x: -1 * Theme.horizontalPageMargin
                interactive: false
                height: count > 0 ? contentHeight : 0

                model: ListModel {
                    id: relatedQuestions
                }

                delegate: BackgroundItem {
                    width: listView.width
                    height: questionTitle.height + 2 * Theme.horizontalPageMargin

                    Label {
                        id: questionTitle
                        text: title
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Theme.horizontalPageMargin
                        anchors.rightMargin: Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: Text.WordWrap
                    }

                    onClicked: Utils.handleLink(url)
                }
            }
        }
    }

    Component.onCompleted: {
        if (question.related){
            for (var i=0; i<question.related.length; i++){
                relatedQuestions.append(question.related[i])
            }
        }
    }
}
