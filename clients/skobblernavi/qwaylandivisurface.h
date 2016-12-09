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

#ifndef QWAYLANDIVISURFACE_H
#define QWAYLANDIVISURFACE_H

#include <QDebug>
#include <QtWaylandClient/private/qwaylandwindow_p.h>
#include "qwayland-ivi-application.h"
#include "qwayland-ivi-controller.h"

namespace QtWaylandClient {

class QWaylandWindow;
class QWindow;

class QWaylandIviSurface : public QtWayland::ivi_surface
        , public QtWayland::ivi_controller_surface
{
public:
    QWaylandIviSurface(struct ::ivi_surface *ivi_surface, QWaylandWindow *window);
    QWaylandIviSurface(struct ::ivi_surface *ivi_surface, QWaylandWindow *window,
                       struct ::ivi_controller_surface *iviControllerSurface);
    virtual ~QWaylandIviSurface();
private:
    virtual void ivi_surface_configure(int32_t width, int32_t height) Q_DECL_OVERRIDE;

    QWaylandWindow *mWindow;
};

}

#endif // QWAYLANDIVISURFACE_H
