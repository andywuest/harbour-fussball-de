/*
 * harbour-fussball-de - Sailfish OS Version
 * Copyright © 2026 Andreas Wüst (andreas.wuest.freelancer@gmail.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    ListModel {
        id: competitionsModel
    }

    function loadCompetitions() {
        competitionsModel.clear()

        var competitions = []
        try {
            competitions = JSON.parse(settings.competitionsString)
        } catch (e) {
            competitions = []
        }
        if (!(competitions instanceof Array)) {
            competitions = []
        }

        for (var i = 0; i < competitions.length; i++) {
            competitionsModel.append({
                                         "description": competitions[i].description ? competitions[i].description : "",
                                         "competitionId": competitions[i].competitionId ? competitions[i].competitionId : ""
                                     })
        }
    }

    function selectCompetition(competitionId) {
        if (competitionId.length === 0) {
            return
        }

        settings.currentCompetitionId = competitionId
        settings.sync()
        pageStack.pop()
    }

    SilicaListView {
        id: competitionsListView
        anchors.fill: parent
        model: competitionsModel

        header: PageHeader {
            //: CompetitionPage page title
            title: qsTr("Competition")
        }

        delegate: ListItem {
            id: competitionItem
            contentHeight: competitionColumn.height + 2 * Theme.paddingMedium

            onClicked: page.selectCompetition(model.competitionId)

            Column {
                id: competitionColumn
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    width: parent.width
                    text: model.description.length > 0 ? model.description : model.competitionId
                    color: competitionItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    width: parent.width
                    visible: model.description.length > 0
                    text: model.competitionId
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: competitionItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    truncationMode: TruncationMode.Fade
                }
            }

            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                width: Theme.iconSizeSmall
                height: width
                source: "image://theme/icon-m-accept"
                visible: model.competitionId === settings.currentCompetitionId
            }
        }

        VerticalScrollDecorator {}
    }

    Component.onCompleted: page.loadCompetitions()
}
