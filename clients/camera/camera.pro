PREFIX=/usr
QT += quickwidgets widgets quick
QT += waylandclient-private
CONFIG += wayland-scanner

!contains(QT_CONFIG, no-pkg-config) {
    PKGCONFIG += wayland-client wayland-cursor
    CONFIG += link_pkgconfig
} else {
    LIBS += -lwayland-client -lwayland-cursor
}

WAYLANDCLIENTSOURCES += \
    ../protocol/ivi-application.xml \
    ../protocol/ivi-controller.xml

LOCAL_SOURCES = main.cpp camera.cpp qwaylandivisurface.cpp
LOCAL_HEADERS = camera.h qwaylandivisurface.h

SOURCES += $$LOCAL_SOURCES
HEADERS += $$LOCAL_HEADERS
RESOURCES += camera.qrc

output.files = camera
output.path = $$PREFIX/bin
INSTALLS += output
