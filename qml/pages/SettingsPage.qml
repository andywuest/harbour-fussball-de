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
import QtQuick.Window 2.0

Page {
    id: settingsPage

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

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

    function addCompetition() {
        var competitionId = competitionIdField.text.trim()
        if (competitionId.length === 0) {
            return
        }

        competitionsModel.append({
                                     "description": descriptionField.text.trim(
                                                        ),
                                     "competitionId": competitionId
                                 })

        descriptionField.text = ""
        competitionIdField.text = ""
        descriptionField.focus = false
        competitionIdField.focus = false
    }

    function removeCompetition(index) {
        if (index >= 0 && index < competitionsModel.count) {
            competitionsModel.remove(index)
        }
    }

    function saveCompetitions() {
        var competitions = []
        for (var i = 0; i < competitionsModel.count; i++) {
            var entry = competitionsModel.get(i)
            competitions.push({
                                  "description": entry.description,
                                  "competitionId": entry.competitionId
                              })
        }
        settings.competitionsString = JSON.stringify(competitions)
        settings.sync()
    }

    SilicaFlickable {
        id: settingsFlickable

        anchors.fill: parent
        // Tell SilicaFlickable the height of its content.
        contentHeight: settingsColumn.height
        contentWidth: parent.width

        Column {
            id: settingsColumn
            width: settingsPage.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: pageHeader
                //: SettingsPage settings title
                title: qsTr("Settings")
            }

            TextField {
                id: descriptionField
                width: parent.width
                label: qsTr("Competition description")
                placeholderText: qsTr("Optional description of the competition")
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: competitionIdField.focus = true
            }

            TextField {
                id: competitionIdField
                width: parent.width
                label: qsTr("Competition ID")
                description: qsTr("Please provide the competition ID extracted from the website that includes the widget.")
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: settingsPage.addCompetition()
            }

            Button {
                id: addButton
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Add")
                enabled: competitionIdField.text.trim().length > 0
                onClicked: settingsPage.addCompetition()
            }

            SilicaListView {
                id: competitionsListView
                height: settingsFlickable.height - descriptionField.height
                        - competitionIdField.height - addButton.height
                        - pageHeader.height - 4 * Theme.paddingLarge
                width: parent.width
                anchors.left: parent.left
                anchors.right: parent.right

                clip: true

                model: ListModel {
                    id: competitionsModel
                }

                delegate: ListItem {
                    id: competitionItem
                    contentHeight: competitionColumn.height + 2 * Theme.paddingMedium

                    menu: ContextMenu {
                        MenuItem {
                            text: qsTr("Remove")
                            onClicked: settingsPage.removeCompetition(index)
                        }
                    }

                    Column {
                        id: competitionColumn
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2 * Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            width: parent.width
                            text: model.description.length
                                  > 0 ? model.description : model.competitionId
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
                }

                VerticalScrollDecorator {}
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            descriptionField.text = ""
            competitionIdField.text = ""
            loadCompetitions()
        } else if (status === PageStatus.Deactivating) {
            saveCompetitions()
        }
    }
}
