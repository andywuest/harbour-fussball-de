# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-fussball-de

CONFIG += sailfishapp

QT += network

SOURCES += src/harbour-fussball-de.cpp \
    src/fontobfuscation/fontdecoder.cpp \
    src/fussballbackend.cpp

HEADERS += src/constants.h \
    src/fontobfuscation/fontdecoder.h \
    src/fontobfuscation/agl_data.h \
    src/fontobfuscation/post_names.h \
    src/fussballbackend.h

DEFINES += VERSION_NUMBER=\\\"$$(VERSION_NUMBER)\\\"

LIBS += -lz

# Opal QML modules (bundled in qml/modules, see libs/module_opal-tabs.txt)
include(libs/opal.pri)

DISTFILES += qml/harbour-fussball-de.qml \
    qml/cover/CoverPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/OverviewPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/TablePage.qml \
    qml/pages/TabsPage.qml \
    qml/components/thirdparty/AboutDescription.qml \
    qml/components/thirdparty/AboutIconLabel.qml \
    qml/components/thirdparty/LoadingIndicator.qml \
    qml/components/GameResultListItem.qml \
    qml/components/TableListItem.qml \
    qml/modules/Opal/Tabs/qmldir \
    qml/modules/Opal/Tabs/SILICA-LICENSE \
    qml/modules/Opal/Tabs/Tab.qml \
    qml/modules/Opal/Tabs/TabItem.qml \
    qml/modules/Opal/Tabs/TabView.qml \
    qml/modules/Opal/Tabs/private/qmldir \
    qml/modules/Opal/Tabs/private/ColorInterpolator.qml \
    qml/modules/Opal/Tabs/private/TabBar.qml \
    qml/modules/Opal/Tabs/private/TabButton.qml \
    qml/modules/Opal/Tabs/private/Util.js \
    rpm/harbour-fussball-de.changes.in \
    rpm/harbour-fussball-de.changes.run.in \
    rpm/harbour-fussball-de.spec \
    qml/pages/icons/github.svg \
    qml/pages/icons/liberapay.svg \
    qml/pages/icons/paypal.svg \
    translations/*.ts \
    harbour-fussball-de.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-fussball-de-de.ts
