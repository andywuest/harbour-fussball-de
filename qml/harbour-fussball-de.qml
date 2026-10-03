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

        property string competitionId: "ac5e71aa-1ee8-4579-9508-1a2f27fe240d"
        property int currentMatchDay: 0
    }
}
