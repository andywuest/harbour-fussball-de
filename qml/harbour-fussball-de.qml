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
import Nemo.Configuration 1.0
import "pages"

ApplicationWindow {
    initialPage: Component { TabsPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-fussball-de/settings"

        // JSON encoded list of configured competitions, each entry holds a
        // description and a competition id, e.g. [{"description":"...","competitionId":"..."}]
        property string competitionsString: "[]"
        // Id of the competition that is currently displayed.
        property string currentCompetitionId: "ac5e71aa-1ee8-4579-9508-1a2f27fe240d"
        // JSON encoded map of the currently selected match day per competition,
        // e.g. {"<competitionId>":2} (match day index starts with 0).
        property string matchDaysString: "{}"

        function matchDays() {
            var days = {}
            try {
                days = JSON.parse(matchDaysString)
            } catch (e) {
                days = {}
            }
            if (!days || typeof days !== "object") {
                days = {}
            }
            return days
        }

        function storedMatchDay(competitionId) {
            var day = matchDays()[competitionId]
            return typeof day === "number" && day >= 0 ? day : 0
        }

        function storeMatchDay(competitionId, matchDayIndex) {
            if (competitionId.length === 0) {
                return
            }
            var days = matchDays()
            days[competitionId] = matchDayIndex
            matchDaysString = JSON.stringify(days)
            sync()
        }

        function removeStoredMatchDays(competitionIds) {
            var days = matchDays()
            var changed = false
            for (var id in days) {
                if (competitionIds.indexOf(id) === -1) {
                    delete days[id]
                    changed = true
                }
            }
            if (changed) {
                matchDaysString = JSON.stringify(days)
                sync()
            }
        }
    }
}
