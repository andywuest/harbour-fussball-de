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

CoverBackground {
    id: cover

    property var matchList: []
    property int currentIndex: 0
    property var currentMatch: matchList.length > 0 ? matchList[currentIndex] : null

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

    function buildMatch(match) {
        var home = match.homeTeam ? match.homeTeam : {}
        var guest = match.guestTeam ? match.guestTeam : {}
        var kickoff = match.kickoff ? match.kickoff : {}
        var homeName = home.name ? home.name : ""
        var awayName = guest.name ? guest.name : ""
        var homeLogoUrl = home.clubLogoURL ? home.clubLogoURL : ""
        var awayLogoUrl = guest.clubLogoURL ? guest.clubLogoURL : ""
        return {
            matchDate: (kickoff.dateWithWeekday ? kickoff.dateWithWeekday + " " : "") + (kickoff.time ? kickoff.time : ""),
            homeTeamName: homeName,
            homeTeamLogo: homeName ? homeName[0] : "",
            homeTeamLogoSource: homeLogoUrl,
            homeTeamLogoUrl: localLogo(homeLogoUrl),
            homeTeamLogoColor: logoColor(homeName),
            awayTeamName: awayName,
            awayTeamLogo: awayName ? awayName[0] : "",
            awayTeamLogoSource: awayLogoUrl,
            awayTeamLogoUrl: localLogo(awayLogoUrl),
            awayTeamLogoColor: logoColor(awayName),
            homeGoals: match.result && match.result.homeResult ? parseInt(match.result.homeResult) : 0,
            awayGoals: match.result && match.result.guestResult ? parseInt(match.result.guestResult) : 0
        }
    }

    function applyResult(decodedJson) {
        var pageProps = decodedJson.pageProps ? decodedJson.pageProps : {}
        var matches = pageProps.matches ? pageProps.matches : []
        var list = []
        for (var i = 0; i < matches.length; ++i)
            list.push(buildMatch(matches[i]))
        matchList = list
        if (currentIndex >= list.length)
            currentIndex = 0
    }

    function updateLogo(logoUrl, localUrl) {
        var changed = false
        for (var i = 0; i < matchList.length; ++i) {
            var match = matchList[i]
            if (match.homeTeamLogoSource === logoUrl) {
                match.homeTeamLogoUrl = localUrl
                changed = true
            }
            if (match.awayTeamLogoSource === logoUrl) {
                match.awayTeamLogoUrl = localUrl
                changed = true
            }
        }
        if (changed)
            matchList = matchList.slice()
    }

    function nextMatch() {
        if (matchList.length > 0)
            currentIndex = (currentIndex + 1) % matchList.length
    }

    function previousMatch() {
        if (matchList.length > 0)
            currentIndex = (currentIndex - 1 + matchList.length) % matchList.length
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2 * Theme.paddingLarge
        spacing: Theme.paddingMedium
        visible: cover.currentMatch !== null

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: cover.currentMatch ? cover.currentMatch.matchDate : ""
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeTiny
            maximumLineCount: 1
            truncationMode: TruncationMode.Elide
        }

        Column {
            id: homeColumn
            width: parent.width
            spacing: Theme.paddingSmall

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.iconSizeMedium
                height: width

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: cover.currentMatch ? cover.currentMatch.homeTeamLogoColor : Theme.highlightColor
                    visible: !cover.currentMatch || cover.currentMatch.homeTeamLogoUrl.length === 0

                    Label {
                        anchors.centerIn: parent
                        text: cover.currentMatch ? cover.currentMatch.homeTeamLogo : ""
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                    }
                }

                Image {
                    anchors.fill: parent
                    source: cover.currentMatch ? cover.currentMatch.homeTeamLogoUrl : ""
                    visible: cover.currentMatch && cover.currentMatch.homeTeamLogoUrl.length > 0
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: width
                    sourceSize.height: height
                }
            }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: cover.currentMatch ? cover.currentMatch.homeTeamName : ""
                maximumLineCount: 1
                truncationMode: TruncationMode.Elide
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        Label {
            id: scoreLabel
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: cover.currentMatch ? cover.currentMatch.homeGoals + " : " + cover.currentMatch.awayGoals : ""
            font.pixelSize: Theme.fontSizeLarge
            font.bold: true
            color: Theme.highlightFromColor(Theme.primaryColor, 0.15)
        }

        Column {
            id: awayColumn
            width: parent.width
            spacing: Theme.paddingSmall

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.iconSizeMedium
                height: width

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: cover.currentMatch ? cover.currentMatch.awayTeamLogoColor : Theme.highlightColor
                    visible: !cover.currentMatch || cover.currentMatch.awayTeamLogoUrl.length === 0

                    Label {
                        anchors.centerIn: parent
                        text: cover.currentMatch ? cover.currentMatch.awayTeamLogo : ""
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.bold: true
                    }
                }

                Image {
                    anchors.fill: parent
                    source: cover.currentMatch ? cover.currentMatch.awayTeamLogoUrl : ""
                    visible: cover.currentMatch && cover.currentMatch.awayTeamLogoUrl.length > 0
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: width
                    sourceSize.height: height
                }
            }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: cover.currentMatch ? cover.currentMatch.awayTeamName : ""
                maximumLineCount: 1
                truncationMode: TruncationMode.Elide
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }

    Label {
        anchors.centerIn: parent
        visible: cover.currentMatch === null
        text: qsTr("No results")
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeSmall
    }

    CoverActionList {
        enabled: cover.matchList.length > 0

        CoverAction {
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: cover.previousMatch()
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: cover.nextMatch()
        }
    }

    Connections {
        target: fussballBackend
        onResultReady: cover.applyResult(decodedJson)
        onLogoReady: cover.updateLogo(logoUrl, localFileUrl)
        onLoadFailed: console.log("FussballBackend error: " + error)
    }
}
