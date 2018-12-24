import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../js/utils.js" as Utils

Page {
    id: root

    property variant question: ({})
    property int p: 1
    property string sort: "votes"
    property bool loading: false

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            anchors {
                left: parent.left
                right: parent.right
            }

            PullDownMenu {
                MenuItem {
                    text: qsTr("View in browser")
                    onClicked: {
                        Utils.handleLink(question.url, true)
                    }
                }
            }

            PageHeader {
                title: question.title || ""
            }

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                }

                Flow {
                    spacing: Theme.paddingMedium
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin

                    Repeater {
                        model: ListModel {
                            id: tagsModel
                        }

                        Rectangle {
                            height: tagLbl.height + Theme.paddingSmall
                            width: tagLbl.width + 2 * Theme.paddingMedium
                            color: tagMouse.pressed ? Theme.highlightBackgroundColor : "transparent"
                            border.width: 1
                            border.color: Theme.secondaryColor

                            Label {
                                id: tagLbl
                                text: model.name
                                font.pixelSize: Theme.fontSizeSmall
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                color: tagMouse.pressed ? Theme.primaryColor : Theme.highlightColor

                                MouseArea {
                                    id: tagMouse
                                    anchors.fill: parent
                                    onClicked: {
                                        pageStack.push(Qt.resolvedUrl("QuestionsPage.qml"), {tags: model.name, compactView: true})
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    // separator
                    color: "transparent"
                    width: parent.width
                    height: Theme.paddingMedium
                }

                Label {
                    text: question.body || ""
                    color: Theme.primaryColor
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                    textFormat: Text.StyledText
                    linkColor: Theme.highlightColor
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        right: parent.right
                        rightMargin: Theme.paddingMedium
                    }
                    onLinkActivated: {
                        if (!loading){
                            Utils.handleLink(link)
                        }
                    }
                }

                Row {
                    visible: !usersModel.count
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.paddingSmall
                    height: busyIndicator.height + 2 * Theme.paddingLarge

                    Image {
                        visible: !busyIndicator.visible
                        source: "image://theme/icon-s-high-importance"
                        width: Theme.iconSizeSmall
                        height: Theme.iconSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    BusyIndicator {
                        id: busyIndicator
                        running: true
                        size: BusyIndicatorSize.Small
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Label {
                        text: {
                            if (question.body){
                                busyIndicator.visible ? qsTr("Loading anwsers") + "..." : qsTr("Failed")
                            }else if(question.id){
                                busyIndicator.visible ? qsTr("Loading question") + "..." : qsTr("Failed")
                            }
                        }
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Column {
                    width: parent.width
                    visible: !!usersModel.count

                    Hr {
                        width: parent.width
                    }

                    Repeater {
                        model: ListModel {
                            id: usersModel
                        }

                        Rectangle {
                            width: parent.width
                            height: userInfo.height + userInfoHr.height
                            color: "transparent"

                            UserInfo {
                                id: userInfo
                                dataModel: model
                                anchors {
                                    left: parent.left
                                    leftMargin: Theme.horizontalPageMargin
                                    right: parent.right
                                    rightMargin: Theme.horizontalPageMargin
                                }
                            }

                            Hr {
                                id: userInfoHr
                                width: parent.width
                                anchors.top: userInfo.bottom
                                visible: index < usersModel.count - 1
                            }
                        }
                    }

                    Hr {
                        width: parent.width
                        paddingBottom: Theme.paddingMedium
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.horizontalPageMargin
                        anchors.right: parent.right
                        height: Math.max(voteCol.height, commentsListView.height)

                        Item {
                            id: voteCol
                            width: Theme.itemSizeSmall
                            height: voteUpBtn.height + voteDownBtn.height + voteLabel.height

                            VoteUpButton {
                                id: voteUpBtn
                                width: Theme.iconSizeMedium
                                anchors.horizontalCenter: parent.horizontalCenter
                                onClicked: {
                                    if (loading) return
                                    loading = true

                                    py.call('app.api.do_vote', [question.id, 1], function(rs){
                                        loading = false

                                        if (rs && rs.success === 1){
                                            question.score = rs.count
                                        }
                                    })
                                }
                            }

                            Label {
                                id: voteLabel
                                text: question.score || '0'
                                anchors.top: voteUpBtn.bottom
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                            }

                            VoteDownButton {
                                id: voteDownBtn
                                width: Theme.iconSizeMedium
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: voteLabel.bottom
                                onClicked: {
                                    if (loading) return
                                    loading = true

                                    py.call('app.api.do_vote', [question.id, 2], function(rs){
                                        loading = false

                                        if (rs && rs.success === 1){
                                            question.score = rs.count
                                        }
                                    })
                                }
                            }
                        }

                        ListView {
                            id: commentsListView
                            interactive: false
                            height: contentHeight
                            width: parent.width - voteCol.width

                            model: ListModel {
                                id: commentsModel
                            }

                            delegate: Item {
                                width: parent.width
                                height: comments.height + (commentsHr.visible ? commentsHr.height : 0)

                                Comment {
                                    id: comments
                                    dataModel: model
                                    anchors.left: parent.left
                                    anchors.leftMargin: Theme.paddingMedium
                                    anchors.right: parent.right
                                    anchors.rightMargin: Theme.paddingMedium

                                    Hr {
                                        id: commentsHr
                                        paddingTop: Theme.paddingMedium
                                        paddingBottom: Theme.paddingMedium
                                        anchors.top: parent.bottom
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        visible: index < commentsModel.count - 1
                                    }
                                }
                            }
                        }

                        CommentButton {
                            label: qsTr("no comment")
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.horizontalPageMargin + Theme.itemSizeSmall
                            anchors.right: parent.right
                            padding: Theme.paddingMedium
                            visible: false//!commentsModel.count
                        }
                    }

                    Hr {
                        width: parent.width
                        paddingBottom: Theme.paddingLarge
                        paddingTop: Theme.paddingMedium
                    }

                    Label {
                        text: question ? (question.answer_count + " " + (qsTr("Answers"))) : ""
                        color: Theme.primaryColor
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.horizontalPageMargin
                    }

                    Hr {
                        width: parent.width
                        paddingTop: Theme.paddingLarge
                    }

                    Repeater {
                        model: ListModel {
                            id: answerModel
                        }

                        Rectangle {
                            width: parent.width - Theme.paddingSmall
                            height: answer.height
                            color: "transparent"

                            Answer {
                                id: answer
                                dataModel: model
                                questionModel: question
                                width: parent.width
                            }
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator {}

        PushUpMenu {
            id: pushUpMenu
            visible: false

            MenuItem {
                text: loading ? qsTr("Loading...") : qsTr("Load more")
                onClicked: {
                    if (!loading){
                        pushUpMenu.busy = true
                        p += 1
                        refresh()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        py.setHandler('question.error', function(){
            busyIndicator.visible = false
            loading = false
        })

        if (question.tags && question.tags.count){
            for (var i=0; i<question.tags.count; i++){
                tagsModel.append(question.tags.get(i))
            }
        }

        refresh()
    }

    function refresh(){
        if (question.body){
            loading = true

            py.call('app.api.get_question', [{id: question.id, url: question.url, author: question.author, page: p, sort: sort}], function(rs){
                pushUpMenu.busy = false
                loading = false

                if (rs.followers){
                    question.followers = rs.followers
                }
                if (rs.following){
                    question.following = rs.following
                }
                if (rs.related){
                    question.related = rs.related
                }
                if (rs.comments){
                    for (var i=0; i<rs.comments.length; i++){
                        commentsModel.append(rs.comments[i])
                    }
                }
                if (rs.answers){
                    for (var i=0; i<rs.answers.length; i++){
                        answerModel.append(rs.answers[i])
                    }
                }
                if (rs.users){
                    for (var i=0; i<rs.users.length; i++){
                        usersModel.append(rs.users[i])
                    }
                }
                if (rs.has_pages){
                    pushUpMenu.visible = true
                }else{
                    pushUpMenu.visible = false
                }

                pageStack.pushAttached(Qt.resolvedUrl("QuestionExtrasPage.qml"), {question: question})
            })
        }else if (question.id){
            py.call("app.api.get_question_by_id", [question.id], function(rs){
                if (rs){
                    question = rs

                    if (question.tags && question.tags.length){
                        for (var i=0; i<question.tags.length; i++){
                            tagsModel.append(question.tags[i])
                        }
                    }

                    refresh()
                }
            })
        }
    }
}
