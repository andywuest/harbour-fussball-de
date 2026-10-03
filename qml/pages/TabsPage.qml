import QtQuick 2.2
import Sailfish.Silica 1.0
import Opal.Tabs 1.0
import "../components"
import "../components/thirdparty"

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    property string competitionName
    property int currentMatchDay: settings.currentMatchDay
    property int maxMatchDay: 0
    property bool loaded: false

    // The models are defined here, so that they can be filled by the functions below.
    ListModel {
        id: gameDayModel
    }

    ListModel {
        id: tableModel
    }

    function loadMatchDay(matchDayIndex) {
        loaded = false
        page.currentMatchDay = matchDayIndex
        settings.currentMatchDay = matchDayIndex
        settings.sync()
        fussballBackend.getMatchDay(matchDayIndex + 1)
    }

    function logoColor(name) {
        var palette = ["#4a90d9", "#3cb371", "#d9a441", "#b03a3a", "#8e44ad", "#d35400",
                       "#2980b9", "#16a085", "#c0392b", "#3498db", "#1abc9c", "#e67e22"]
        var hash = 0
        for (var i = 0; i < name.length; ++i)
            hash = (hash * 31 + name.charCodeAt(i)) % 0xFFFFFF
        return palette[hash % palette.length]
    }

    function localLogo(logoUrl) {
        if (!logoUrl)
            return ""
        var localUrl = fussballBackend.cachedLogoUrl(logoUrl)
        if (localUrl.length === 0)
            fussballBackend.cacheLogo(logoUrl)
        return localUrl
    }

    function updateGameDayLogo(logoUrl, localUrl) {
        for (var i = 0; i < gameDayModel.count; ++i) {
            var match = gameDayModel.get(i)
            if (match.homeTeamLogoSource === logoUrl)
                gameDayModel.setProperty(i, "homeTeamLogoUrl", localUrl)
            if (match.awayTeamLogoSource === logoUrl)
                gameDayModel.setProperty(i, "awayTeamLogoUrl", localUrl)
        }
    }

    function updateTableLogo(logoUrl, localUrl) {
        for (var i = 0; i < tableModel.count; ++i) {
            if (tableModel.get(i).teamLogoSource === logoUrl)
                tableModel.setProperty(i, "teamLogoUrl", localUrl)
        }
    }

    function applyResult(decodedJson) {
        // console.log("Game day result: " + JSON.stringify(decodedJson))

        var pageProps = decodedJson.pageProps ? decodedJson.pageProps : {}
        competitionName = pageProps.competitionName ? pageProps.competitionName : ""
        var matchDays = pageProps.matchDays ? pageProps.matchDays : []
        maxMatchDay = matchDays.length
        currentMatchDay = pageProps.currentMatchDay > 0 ? (pageProps.currentMatchDay - 1) : 0

        fillGameDay(pageProps.matches ? pageProps.matches : [])
        fillTable(pageProps.table && pageProps.table.entries ? pageProps.table.entries : [])
    }

    function fillGameDay(matches) {
        gameDayTab.title = qsTr("%1. Spieltag").arg(currentMatchDay + 1)
        gameDayModel.clear()
        for (var i = 0; i < matches.length; ++i) {
            var match = matches[i]
            var home = match.homeTeam ? match.homeTeam : {}
            var guest = match.guestTeam ? match.guestTeam : {}
            var kickoff = match.kickoff ? match.kickoff : {}
            var homeLogoUrl = home.clubLogoURL ? home.clubLogoURL : ""
            var awayLogoUrl = guest.clubLogoURL ? guest.clubLogoURL : ""
            gameDayModel.append({
                matchDate: (kickoff.dateWithWeekday ? kickoff.dateWithWeekday + " " : "") + (kickoff.time ? kickoff.time : ""),
                homeTeamName: home.name ? home.name : "",
                homeTeamLogo: home.name ? home.name[0] : "",
                homeTeamLogoSource: homeLogoUrl,
                homeTeamLogoUrl: localLogo(homeLogoUrl),
                homeTeamLogoColor: logoColor(home.name ? home.name : ""),
                awayTeamName: guest.name ? guest.name : "",
                awayTeamLogo: guest.name ? guest.name[0] : "",
                awayTeamLogoSource: awayLogoUrl,
                awayTeamLogoUrl: localLogo(awayLogoUrl),
                awayTeamLogoColor: logoColor(guest.name ? guest.name : ""),
                homeGoals: match.result && match.result.homeResult ? parseInt(match.result.homeResult) : 0,
                awayGoals: match.result && match.result.guestResult ? parseInt(match.result.guestResult) : 0
            })
        }
    }

    function fillTable(entries) {
        tableModel.clear()
        for (var i = 0; i < entries.length; ++i) {
            var entry = entries[i]
            console.log("adding to table model : " + entry.teamName[0])
            var logoUrl = entry.clubLogoURL ? entry.clubLogoURL : ""

            var createdModel = {
                            position: entry.position ? entry.position : "",
                            teamName: entry.teamName ? entry.teamName : "",
                            teamLogo: entry.teamName ? entry.teamName[0] : "",
                            teamLogoSource: logoUrl,
                            teamLogoUrl: localLogo(logoUrl),
                            teamLogoColor: logoColor(entry.teamName ? entry.teamName : ""),
                            matches: entry.matches ? entry.matches : "0",
                            won: entry.matchesWon ? entry.matchesWon : "0",
                            drawn: entry.matchesDrawn ? entry.matchesDrawn : "0",
                            lost: entry.matchesLost ? entry.matchesLost : "0",
                            goalRatio: entry.goalRatio ? entry.goalRatio : "0:0",
                            goalDifference: entry.goalDifference ? entry.goalDifference : "0",
                            points: entry.points ? entry.points : "0"
                        }            ;
            console.log(JSON.stringify(createdModel));

            tableModel.append(createdModel)
        }
    }

    TabView {
        id: tabView

        anchors.fill: parent

        // The pull down menus are only supported with the tab bar at the top.
        tabBarPosition: Qt.AlignTop

        Tab {
            id: gameDayTab
            title: qsTr("Spieltag")           

            Component {
                TabItem {
                    flickable: gameDayListView

                    SilicaFlickable {
                        id: gameDayListView
                        anchors.fill: parent

                        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
                        PullDownMenu {
                            MenuItem {
                                text: qsTr("About")
                                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                            }
                            MenuItem {
                                text: qsTr("Settings")
                                onClicked: pageStack.animatorPush(Qt.resolvedUrl("SettingsPage.qml"))
                            }
                            MenuItem {
                                visible: page.currentMatchDay > 0
                                text: qsTr("Previous match day")
                                onClicked: page.loadMatchDay(page.currentMatchDay - 1)
                            }
                            MenuItem {
                                visible: page.currentMatchDay < page.maxMatchDay - 1
                                text: qsTr("Next match day")
                                onClicked: page.loadMatchDay(page.currentMatchDay + 1)
                            }
                        }

                        SilicaListView {
                            model: gameDayModel
                            anchors.fill: parent

                            delegate: GameResultListItem {
                                matchDate: model.matchDate
                                homeTeamName: model.homeTeamName
                                homeTeamLogo: model.homeTeamLogo
                                homeTeamLogoUrl: model.homeTeamLogoUrl
                                homeTeamLogoColor: model.homeTeamLogoColor
                                awayTeamName: model.awayTeamName
                                awayTeamLogo: model.awayTeamLogo
                                awayTeamLogoUrl: model.awayTeamLogoUrl
                                awayTeamLogoColor: model.awayTeamLogoColor
                                homeGoals: model.homeGoals
                                awayGoals: model.awayGoals
                            }

                            VerticalScrollDecorator {}
                        }

                    }

                    LoadingIndicator {
                        visible: !page.loaded
                        Behavior on opacity {
                            NumberAnimation {
                            }
                        }
                        opacity: page.loaded ? 0 : 1
                        height: parent.height
                        width: parent.width
                    }
                }
            }
        }

        Tab {
            title: qsTr("Tabelle")

            Component {

                TabItem {
                    flickable: tableListView

                    SilicaFlickable {
                        id: tableListView
                        anchors.fill: parent

                        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
                        PullDownMenu {
                            MenuItem {
                                text: qsTr("About")
                                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                            }
                            MenuItem {
                                text: qsTr("Settings")
                                onClicked: pageStack.animatorPush(Qt.resolvedUrl("SettingsPage.qml"))
                            }
                            MenuItem {
                                visible: page.currentMatchDay > 0
                                text: qsTr("Previous match day")
                                onClicked: page.loadMatchDay(page.currentMatchDay - 1)
                            }
                            MenuItem {
                                visible: page.currentMatchDay < page.maxMatchDay - 1
                                text: qsTr("Next match day")
                                onClicked: page.loadMatchDay(page.currentMatchDay + 1)
                            }
                        }


                        SilicaListView {
                            model: tableModel
                            anchors.fill: parent

                            delegate: TableListItem {
                                position: model.position
                                teamName: model.teamName
                                teamLogo: model.teamLogo
                                teamLogoUrl: model.teamLogoUrl
                                teamLogoColor: model.teamLogoColor
                                matches: model.matches
                                won: model.won
                                drawn: model.drawn
                                lost: model.lost
                                goalRatio: model.goalRatio
                                goalDifference: model.goalDifference
                                points: model.points
                            }

                            VerticalScrollDecorator {}
                        }

                    }
                }
            }
        }
    }

    Connections {
        target: fussballBackend
        onResultReady: {
            page.applyResult(decodedJson)
            page.loaded = true
        }
        onLoadFailed: {
            console.log("FussballBackend error: " + error)
            page.loaded = true
        }
        onLogoReady: {
            page.updateGameDayLogo(logoUrl, localFileUrl)
            page.updateTableLogo(logoUrl, localFileUrl)
        }
    }

    Component.onCompleted: {
        page.loadMatchDay(settings.currentMatchDay)
    }
}
