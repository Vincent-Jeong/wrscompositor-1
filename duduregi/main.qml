import QtQuick 2.1
import "compositor.js" as CompositorLogic
import "config.js" as Conf
import "sprintf.js" as SPrintf
import com.windriver.automotive 1.0
import com.windriver.genivi 1.0

Item {
    id: root

    property variant currentWindow: null
    property variant waitProcess: null

    property variant selectedWindow: null
    property bool hasFullscreenWindow: typeof compositor != "undefined" && compositor.fullscreenSurface !== null

    onHasFullscreenWindowChanged: {
        console.log("has fullscreen window: " + hasFullscreenWindow);
    }


    VNADBusClient {
        id: vna_dbusClient

        onVehicleInfoChanged: {
            if(false) {
                console.log('vehicleInfoChanged : '+vehicleInfoWMI);
                console.log('vehicleInfoChanged : '+speedometer);
            }
            statusBar.setWMI(vehicleInfoWMI)
        }
    }

    WRDBusClient {
        id: wr_dbusClient

        onTrackInfoChanged: {
            console.log('title : '+title);
            console.log('playState : '+playState);
            if(playState == 0) // stop
                iPodArtwork.source = 'images/artwork.jpg';
        }
        onArtworkChanged: {
            iPodArtwork.source = 'data:image/png;base64,'+wr_dbusClient.artwork;
        }
    }

    StatusBar {
        id: statusBar
        visible: !mainmenu.androidAutoMode
        //z: mainmenu.androidAutoMode?-1:200
        onHeightChanged: {
            Conf.statusBarHeight = statusBar.height
        }
    }
    Image {
        id: background
        Behavior on opacity {
            NumberAnimation { easing.type: Easing.InCubic; duration: 400; }
        }
        anchors.top: statusBar.bottom
        width: parent.width
        height: parent.height - statusBar.height

        fillMode: Image.PreserveAspectCrop
        source: "alameda.jpg"
        smooth: true

        // window destroy callback
        function removeWindow(windowContainer) {
            console.log('window destroyed '+windowContainer);

            var layer = geniviExt.mainScreen.layerById(1000); // application layer
            layer.removeSurface(windowContainer.ivi_surface);
            windowContainer.destroy();
            CompositorLogic.removeWindow(windowContainer);
        }


        Item {
            id: currentApp
            anchors.fill: parent
        }

        Rectangle {
            id: ipodWidget
            clip: true
            anchors.left: parent.left
            anchors.leftMargin: background.width / 20
            anchors.top: parent.top
            anchors.topMargin: background.height / 20
            width: parent.width/2
            height: parent.height/3
            color: "transparent"
            Rectangle {
                id: iPodWidgetBG
                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width
                height: parent.height
                color: iPodMouseArea.pressed?"blue":"black"
                opacity: 0.5
                radius: 20

                MouseArea {
                    id: iPodMouseArea
                    anchors.top: parent.top
                    anchors.left: parent.left
                    width: parent.width
                    height: parent.height
                    onClicked: {
                        if(wr_dbusClient.playState == 4)
                            wr_dbusClient.pause()
                        else if(wr_dbusClient.playState == 5)
                            wr_dbusClient.play()
                    }
                }

            }

            Image {
                id: iPodArtwork
                source: 'images/artwork.jpg'
                anchors.top: parent.top
                anchors.left: top.left
                anchors.leftMargin: parent.height / 20
                width: parent.height
                height: parent.height
            }
            Text {
                id: iPodMedia
                anchors.top: parent.top
                anchors.topMargin: parent.height / 20
                anchors.left: iPodArtwork.right
                anchors.leftMargin: parent.height / 20
                text: "iPod"
                font.pointSize: parent.height / 10
                color: "white"
                smooth: true
                font.bold: true
                style: Text.Outline
            }
            Text {
                id: iPodArtist
                elide: Text.ElideRight
                anchors.top: iPodMedia.bottom
                anchors.left: iPodMedia.left
                anchors.right: parent.right
                anchors.rightMargin: parent.height / 20
                text: wr_dbusClient.artist
                font.pointSize: parent.height / 10
                color: "white"
                smooth: true
                font.bold: true
                style: Text.Outline
            }
            Text {
                id: iPodAlbum
                elide: Text.ElideRight
                anchors.top: iPodArtist.bottom
                anchors.left: iPodArtist.left
                anchors.right: parent.right
                anchors.rightMargin: parent.height / 20
                text: wr_dbusClient.album
                font.pointSize: parent.height / 10
                color: "white"
                smooth: true
                font.bold: true
                style: Text.Outline
            }
            Text {
                id: iPodTitle
                elide: Text.ElideRight
                anchors.top: iPodAlbum.bottom
                anchors.left: iPodArtist.left
                anchors.right: parent.right
                anchors.rightMargin: parent.height / 20
                text: wr_dbusClient.title
                font.pointSize: parent.height / 10
                color: "white"
                smooth: true
                font.bold: true
                style: Text.Outline
            }
            Text {
                id: iPodStatus
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height / 20
                anchors.left: iPodArtist.left
                text: (wr_dbusClient.playState == 4)?"Playing...":((wr_dbusClient.playState == 5)?"Paused":"")
                font.pointSize: parent.height / 6
                color: "white"
                smooth: true
                font.bold: true
                style: Text.Outline
            }
            Text {
                id: iPodTrackPosition
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height / 20
                anchors.right: parent.right
                anchors.rightMargin: parent.height / 10
                text: SPrintf.sprintf('%02d', parseInt(wr_dbusClient.trackPosition/1000/60))+':'+SPrintf.sprintf('%02d', parseInt((wr_dbusClient.trackPosition/1000)%60))
                font.pointSize: parent.height / 6
                color: "white"
                smooth: true
                font.bold: true
                style: Text.Outline
            }
            //visible: wr_dbusClient.connected > 0 && wr_dbusClient.title != ""
            visible: wr_dbusClient.connected == 1
        }

        Text {
            id: speed
            anchors.right: parent.right
            anchors.rightMargin: background.width / 20
            anchors.bottom: parent.bottom
            text: vna_dbusClient.speedometer+" Km"
            font.pointSize: background.height/5
            color: "white"
            smooth: true
            font.bold: true
            style: Text.Outline
            visible: vna_dbusClient.speedometer
        }

        MainMenu {
            id: mainmenu
            z: 100
            root: root
            Component.onCompleted: {
                statusBar.closeWindow.connect(function() {
                    console.log('close clicked');
                    hide();
                })
                statusBar.logoClicked.connect(function() {
                    if(!mainmenu.visible)
                        mainmenu.show()
                    else
                        menuShowRequested()
                })
                statusBar.closeWindow.connect(function() {
                    console.log('close clicked');
                    hide();
                })
            }
            onMenuActivated: {
                statusBar.showCloseButton(flag);
            }
        }
    }
    /*
    WebView  {
        id: launcher
        //url: "http://0.0.0.0:7070/html5apps/WRLauncher/"
        url: "file:///opt/windriver/wr-amb/www/html5apps/WRLauncher/index.html"
        anchors.fill: parent
        focus: true
        Keys.onPressed: {
            console.log('key '+event.key);
            if (event.key == Qt.Key_F1) {
                console.log('menu');
                launcher.url = "file:///opt/windriver/wr-amb/www/html5apps/WRLauncher/index.html";
            } else if (event.key == Qt.Key_Backspace) {
                console.log('back');
                launcher.goBack();
            }
        }
    }
    */

    /*
    MouseArea {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 2
        height: 2
        hoverEnabled: true
        onEntered: {
            console.log('entered');
            root.selectedWindow = null
            root.focus = true
        }
        z: 10
    }
    */
    function raiseWindow(window) {
        if(root.currentWindow != null)
            root.currentWindow.visible = false
        root.currentWindow = window
        root.currentWindow.visible = true
        if(mainmenu.visible)
            mainmenu.hide();
    }

    function windowAdded(window) {
        console.log('window added '+window);
        console.log('window added title:'+window.title);
        console.log('window added className:'+window.className);
        console.log('window added pid: '+window.client.processId);
        console.log(geniviExt.mainScreen);
        console.log(geniviExt.mainScreen.layerCount());
        console.log(geniviExt.mainScreen.layer(0));
        console.log(geniviExt.mainScreen.layer(0).visibility);
        console.log(currentApp.width+' '+ currentApp.height);

        var androidAutoProjectionWindow = false;
        var layer = geniviExt.mainScreen.layerById(1000); // application layer
        if(window.title == 'gsteglgles') {
            // XXX window from android on Minnow Max target
            androidAutoProjectionWindow = true;
        }

        var windowContainerComponent = Qt.createComponent("WindowFrame.qml");
        var windowContainer;
        if(androidAutoProjectionWindow) { 
            console.log('wayland android auto');
            console.log(mainmenu.androidAutoContainer);
            windowContainer = windowContainerComponent.createObject(mainmenu.androidAutoContainer);
        } else
            windowContainer = windowContainerComponent.createObject(background);

        windowContainer.rootBackground = background
        windowContainer.z = 50
        windowContainer.child = compositor.item(window);
        windowContainer.child.parent = windowContainer;
        windowContainer.child.touchEventsEnabled = true;
        windowContainer.ivi_surface = layer.addSurface(0, 0, window.size.width, window.size.height, windowContainer);
        windowContainer.ivi_surface.id = window.client.processId;

        windowContainer.targetX = 0;
        windowContainer.targetY = 0;
        windowContainer.targetWidth = window.size.width;
        windowContainer.targetHeight = window.size.height - statusBar.height;
        if(androidAutoProjectionWindow) {
            windowContainer.z = -1
            windowContainer.targetX = 0;
            windowContainer.targetY = 0;
            windowContainer.targetWidth = window.size.width;
            windowContainer.targetHeight = window.size.height;
            windowContainer.scaledWidth = Conf.displayWidth/window.size.width;
            windowContainer.scaledHeight = Conf.displayHeight/window.size.height;
        }

        if(root.waitProcess && root.waitProcess.pid == window.client.processId)
        {
            // XXX hard code for AM Monitor
            if(root.waitProcess.cmd.indexOf("onitor")>0) // AM Monitor
            {
                windowContainer.targetY = - statusBar.height;
                windowContainer.targetHeight = window.size.height;
            }
            root.waitProcess.setWindow(windowContainer);
            root.waitProcess = null;
        }

        CompositorLogic.addWindow(windowContainer);

        windowContainer.opacity = 1

        if(!androidAutoProjectionWindow) {
            if(root.currentWindow != null)
                root.currentWindow.visible = false
            root.currentWindow = windowContainer

            if(mainmenu.visible)
                mainmenu.hide();
        }
    }

    function windowResized(window) {
        console.log('window resized '+window);
        window.width = window.surface.size.width;
        window.height = window.surface.size.height;
    }

    Keys.onPressed: {
        console.log('key on main: '+event.key);
        if (event.key == Qt.Key_F1) {
            console.log('[41mF1 - 3 !!!![0m\n');
            mainmenu.show()
        } else if (event.key == Qt.Key_Backspace) {
            console.log('backspace');
            if(mainmenu.visible)
                mainmenu.hide();
        }
    }
    onWidthChanged: {
        Conf.displayWidth = width;
    }
    onHeightChanged: {
        Conf.displayHeight = height;
    }
}
