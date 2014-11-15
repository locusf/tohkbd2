TARGET = harbour-tohkbd2

CONFIG += link_pkgconfig
PKGCONFIG += mlite5

QT += dbus
QT -= gui

system(qdbusxml2cpp config/com.kimmoli.tohkbd2.xml -i src/tohkeyboard.h -a src/adaptor)

DEFINES += "APPVERSION=\\\"$${SPECVERSION}\\\""

target.path = /usr/bin/

systemd.path = /etc/systemd/user/
systemd.files = config/$${TARGET}.service

udevrule.path = /etc/udev/rules.d/
udevrule.files = config/95-$${TARGET}.rules

dbusconf.path = /etc/dbus-1/system.d/
dbusconf.files = config/$${TARGET}.conf

ambience.path = /usr/share/ambience/$${TARGET}
ambience.files = ambience/$${TARGET}.ambience

images.path = $${ambience.path}/images
images.files = ambience/images/*

vkblayout.path = /usr/share/maliit/plugins/com/jolla/layouts/
vkblayout.files = config/layouts/$${TARGET}.conf config/layouts/$${TARGET}.qml

INSTALLS += target systemd udevrule dbusconf ambience images vkblayout

message($${DEFINES})

SOURCES += \
    src/tohkbd2-daemon.cpp \
    src/toh.cpp \
    src/worker.cpp \
    src/tohkeyboard.cpp \
    src/uinputif.cpp \
    src/driverBase.cpp \
    src/tca8424driver.cpp \
    src/keymapping.cpp \
    src/adaptor.cpp

HEADERS += \
    src/toh.h \
    src/worker.h \
    src/tohkeyboard.h \
    src/uinputif.h \
    src/driverBase.h \
    src/tca8424driver.h \
    src/keymapping.h \
    src/adaptor.h

OTHER_FILES += \
    rpm/$${TARGET}.spec \
    config/$${TARGET}.service \
    config/$${TARGET}.conf \
    config/layouts/$${TARGET}.conf \
    config/layouts/$${TARGET}.qml \
    config/com.kimmoli.tohkbd2.xml