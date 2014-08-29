/**************************************************************************
 *
 * Copyright 2010, 2011 BMW Car IT GmbH
 * Copyright (C) 2011 DENSO CORPORATION and Robert Bosch Car Multimedia Gmbh
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include "WLContext.h"
#include "WLEGLSurface.h"
#include "WLEyes.h"
#include "WLEyesRenderer.h"

int gRunLoop = 0;
int gNeedRedraw = 0;
int gPointerX = 0;
int gPointerY = 0;

static void SigFunc(int)
{
    printf("Caught signal\n");
    gRunLoop = 0;
}

int main(int argc, char **argv)
{
    struct sigaction sigint;
    WLContext* wlContext;
    WLEGLSurface* eglSurface;
    WLEyes* eyes;
    t_ilm_layer   layerId   = 1000;
    t_ilm_surface surfaceId = 5100;

    argc = argc; // avoid warning
    argv = argv;

    // signal handling
    sigint.sa_handler = SigFunc;
    sigemptyset(&sigint.sa_mask);
    sigint.sa_flags = SA_RESETHAND;
    sigaction(SIGINT, &sigint, NULL);

    ilm_init();

    wlContext = new WLContext();
    wlContext->InitWLContext(&PointerListener, &KeyboardListener);

    eglSurface = new WLEGLSurface(wlContext);
    eglSurface->CreateSurface(400, 240);
    eglSurface->CreateIlmSurface(&layerId, &surfaceId, 400, 240);

    eyes = new WLEyes(400, 240);

    // initialize eyes renderer
    if (!InitRenderer()){
        fprintf(stderr, "Failed to init renderer\n");
        return -1;
    }

    // draw eyes once
    DrawEyes(eglSurface, eyes);

    // wait for input event
    gRunLoop = 1;
    gNeedRedraw = 0;
    while (gRunLoop){
        WaitForEvent(wlContext->GetWLDisplay());
        if (gNeedRedraw && gRunLoop){
            DrawEyes(eglSurface, eyes);
            gNeedRedraw = 0;
        }
        usleep(50);
    }

    TerminateRenderer();
    eglSurface->DestroyIlmSurface();
    ilm_destroy();
    delete eyes;
    delete eglSurface;
    delete wlContext;

    return 0;
}