#include "viewhelper.h"

#include <stdio.h>

#include <QGuiApplication>
#include <qpa/qplatformnativeinterface.h>

ViewHelper::ViewHelper(QQuickView *parent) :
    QObject(parent),
    view(parent)
{
    m_currentApp = 0;
    m_numberOfApps = 1;
}

void ViewHelper::detachWindow()
{
    view->close();
    view->create();

    QPlatformNativeInterface *native = QGuiApplication::platformNativeInterface();
    native->setWindowProperty(view->handle(), QLatin1String("CATEGORY"), "notification");
    setDefaultRegion();

    //view->showFullScreen();
}

void ViewHelper::setMouseRegion(const QRegion &region)
{
    QPlatformNativeInterface *native = QGuiApplication::platformNativeInterface();
    native->setWindowProperty(view->handle(), QLatin1String("MOUSE_REGION"), region);
}

//void ViewHelper::setTouchRegion(const QRect &rect)
//{
//    setMouseRegion(QRegion(rect));
//}

void ViewHelper::setDefaultRegion()
{
    setMouseRegion(QRegion( (540-480)/2, (960-240)/2 ,480, 240));
}

void ViewHelper::hideWindow()
{
    launchApplication(m_currentApp);
}

void ViewHelper::nextApp()
{
    if (m_numberOfApps > 0)
        m_currentApp = (m_currentApp+1) % m_numberOfApps;

    emit currentAppChanged();
}

int ViewHelper::getCurrentApp()
{
    return m_currentApp;
}

void ViewHelper::launchApplication(int n)
{
    view->hide();

    printf("tohkbd2-user: Starting %s\n", qPrintable(apps.at(n)));

    QProcess proc;
    proc.startDetached("/usr/bin/xdg-open" , QStringList() << apps.at(n));
    QThread::msleep(100);
}

/* Getting shortcuts defined in TOHKBD2, F1 through F8 */
QVariantList ViewHelper::getCurrentShortcuts()
{
    QVariantList tmp;
    QVariantMap map;

    apps.clear();

    apps << "/usr/share/applications/sailfish-browser.desktop";
    apps << "/usr/share/applications/fingerterm.desktop";
    apps << "/usr/share/applications/voicecall-ui.desktop";
    apps << "/usr/share/applications/sailfish-maps.desktop";
    apps << "/usr/share/applications/jolla-camera.desktop";
    apps << "/usr/share/applications/jolla-gallery.desktop";
    apps << "/usr/share/applications/jolla-clock.desktop";
    apps << "/usr/share/applications/jolla-email.desktop";

    m_numberOfApps = apps.count();

    for (int i = 0 ; i<apps.count() ; i++)
    {
        QString appPath = apps.at(i);

        map.clear();
        map.insert("filePath", appPath);

        MDesktopEntry app(appPath);

        if (app.isValid())
        {
            map.insert("name", app.name());
            if (app.icon().startsWith("icon-launcher-") || app.icon().startsWith("icon-l-") || app.icon().startsWith("icons-Applications"))
                map.insert("iconId", QString("image://theme/%1").arg(app.icon()));
            else if (app.icon().startsWith("/"))
                map.insert("iconId", QString("%1").arg(app.icon()));
            else
                map.insert("iconId", QString("/usr/share/icons/hicolor/86x86/apps/%1.png").arg(app.icon()));
        }
        else
        {
            map.insert("name", "Not configured");
            map.insert("iconId", QString());
        }

        tmp.append(map);
    }

    return tmp;
}
