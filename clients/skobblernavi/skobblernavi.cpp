/*
 * Copyright © 2016 Wind River Systems, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "skobblernavi.h"

SkobblerNavi::SkobblerNavi(uint32_t role)
    : QWebView(), QWaylandCommon(role) {

    QUrl url = QUrl("qrc:///html5/index.html");
    load(url);
    installEventFilter(this);
}

SkobblerNavi::~SkobblerNavi() {
}

void SkobblerNavi::configureIviSurface(QWindow *window, int width, int height) {
    QtWaylandClient::QWaylandWindow *qWaylandWindow =
                    (QtWaylandClient::QWaylandWindow *) window->handle();

    qDebug() << "skobblerNavi::configureIviSurface, configure QWaylandWindow size " << width << "," << height;
    QWaylandCommon::configureIviSurface(window, width, height);
 }

bool SkobblerNavi::eventFilter(QObject *obj, QEvent *event) {
    //qDebug() << "SkobblerNavi::eventFilter, event " << event;
    QWebView *webview = qobject_cast<QWebView*>(obj);

    switch (event->type()) {
        case QEvent::Close:
        {
            qDebug() << "SkobberNavi has closed";
            webview->windowHandle()->destroy();
            break;
        }

        case QEvent::PlatformSurface:
        {
            QPlatformSurfaceEvent::SurfaceEventType eventType =
                static_cast<QPlatformSurfaceEvent *>(event)->surfaceEventType();

            if (eventType == QPlatformSurfaceEvent::SurfaceCreated) {
                qDebug() << "SkobberNavi has created surface";
                this->createIviSurface(webview->windowHandle());
            } else if (eventType == QPlatformSurfaceEvent::SurfaceAboutToBeDestroyed) {
                qDebug() << "SkobberNavi has destroyed surface";
            }
            break;
        }

        default:
            break;
    }

    return QObject::eventFilter(obj, event);
}