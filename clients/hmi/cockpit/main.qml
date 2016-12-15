/*
 * Copyright © 2016 Wind River Systems, Inc.
 *
 * The right to copy, distribute, modify, or otherwise make use of this
 * software may be licensed only pursuant to the terms of an applicable
 * Wind River license agreement.
 */
import QtQuick 2.1

Item {
    id: root

    height: 1920
    width: 1024

    property variant currentWindow: null
    property variant waitProcess: null

    signal swapWindowRequested(var anObject)
    signal cloneWindowRequested(var anObject)
    signal closeClonedWindowRequested(var anObject)

    onHasFullscreenWindowChanged: {
        console.log("has fullscreen window: " + hasFullscreenWindow);
    }

    StatusBar {
        id: statusBar
    }

    SidePanel {
        id: sidePanel
        anchors.top: statusBar.bottom
        anchors.right: parent.right
        anchors.bottom: dockBar.top
        width: parent.width * 0.34
    }
    DockBar {
        id: dockBar
        onLaunched: {
            console.log("DockBar, onLaunched");
        }
    }
    Image {
        id: background
        anchors.top: statusBar.bottom
        width: parent.width - sidePanel.width
        height: parent.height - statusBar.height - dockBar.height

        source: "resources/background.jpg"

        Item {
            id: currentApp
            anchors.fill: parent
        }

        MainMenu {
            id: mainmenu
            height: parent.height
            width: parent.width
            windowDefaultWidth: background.width
            windowDefaultHeight: background.height
            androidAutoEnabled: root.androidAutoEnabled
            root: root
            visible: true
            Component.onCompleted: {
            }
            onMenuActivated: {
            }
        }
    }

    Component.onCompleted: {
    }
}
