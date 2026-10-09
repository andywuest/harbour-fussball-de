#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QDir>
#include <QGuiApplication>
#include <QQmlContext>
#include <QQuickView>
#include <QScopedPointer>
#include <QStandardPaths>
#include <QtQml>

#include "constants.h"
#include "fussballbackend.h"

int main(int argc, char *argv[])
{
    QDir fontDir(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
                  + QString("/%1/%2/fonts/").arg(ORGANISATION, APP_NAME));
    QDir logoDir(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
                  + QString("/%1/%2/logos/").arg(ORGANISATION, APP_NAME));

    if (!fontDir.exists()) {
        fontDir.mkpath(fontDir.path());
    }
    if (!logoDir.exists()) {
        logoDir.mkpath(logoDir.path());
    }

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));

    app->setOrganizationDomain(ORGANISATION);
    app->setOrganizationName(ORGANISATION); // needed for Sailjail
    app->setApplicationName(APP_NAME);

    QScopedPointer<QQuickView> view(SailfishApp::createView());

    // add module search path so Opal modules can be found
    view->engine()->addImportPath(SailfishApp::pathTo("qml/modules").toString());

    QQmlContext *context = view.data()->rootContext();
    FussballBackend fussballBackend(fontDir.path(), logoDir.path());
    context->setContextProperty("fussballBackend", &fussballBackend);

    context->setContextProperty("applicationVersion", QString(VERSION_NUMBER));

    view->setSource(SailfishApp::pathTo("qml/harbour-fussball-de.qml"));
    view->show();
    return app->exec();
}
