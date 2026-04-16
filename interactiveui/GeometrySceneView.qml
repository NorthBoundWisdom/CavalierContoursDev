import QtQuick 2.13
import QtQml 2.13
import Polyline 1.0

Rectangle {
    id: rect
    color: "white"
    clip: true
    default property alias content: plineSceneItem.children

    Rectangle {
        id: plineSceneItem
        property real sceneSize: 20000

        QtObject {
            id: interactionState
            property real x1: 0
            property real y1: 0
            property real y2: 0
            property real x2: 0
            property real zoom1: 1
            property real zoom2: 1
            property real maxZoom: 10
            property real minZoom: 0.05
        }

        width: sceneSize
        height: sceneSize
        // Initially center (0,0) based on current viewport size.
        x: (rect.width - width) / 2
        y: (rect.height - height) / 2
        border.width: 1 / scaler.xScale
        border.color: "blue"

        transform: Scale {
            id: scaler
            origin.x: interactionState.x2
            origin.y: interactionState.y2
            xScale: interactionState.zoom2
            yScale: interactionState.zoom2
        }

        PinchArea {
            id: pinchArea
            anchors.fill: parent

            onPinchStarted: {
                interactionState.x1 = scaler.origin.x;
                interactionState.y1 = scaler.origin.y;
                interactionState.x2 = pinch.startCenter.x;
                interactionState.y2 = pinch.startCenter.y;
                plineSceneItem.x = plineSceneItem.x + (interactionState.x1 - interactionState.x2) * (1 - interactionState.zoom1);
                plineSceneItem.y = plineSceneItem.y + (interactionState.y1 - interactionState.y2) * (1 - interactionState.zoom1);
            }
            onPinchUpdated: {
                interactionState.zoom1 = scaler.xScale;
                var dz = pinch.scale - pinch.previousScale;
                var newZoom = interactionState.zoom1 + dz;
                if (newZoom <= interactionState.maxZoom && newZoom >= interactionState.minZoom) {
                    interactionState.zoom2 = newZoom;
                }
            }

            MouseArea {
                id: dragArea
                hoverEnabled: true
                anchors.fill: parent
                drag.target: plineSceneItem
                drag.filterChildren: true
                onWheel: function(wheel) {
                    interactionState.x1 = scaler.origin.x;
                    interactionState.y1 = scaler.origin.y;
                    interactionState.zoom1 = scaler.xScale;

                    interactionState.x2 = mouseX;
                    interactionState.y2 = mouseY;

                    var newZoom;
                    if (wheel.angleDelta.y > 0) {
                        newZoom = interactionState.zoom1 + 0.15;
                        if (newZoom <= interactionState.maxZoom) {
                            interactionState.zoom2 = newZoom;
                        } else {
                            interactionState.zoom2 = interactionState.maxZoom;
                        }
                    } else {
                        newZoom = interactionState.zoom1 - 0.15;
                        if (newZoom >= interactionState.minZoom) {
                            interactionState.zoom2 = newZoom;
                        } else {
                            interactionState.zoom2 = interactionState.minZoom;
                        }
                    }
                    plineSceneItem.x = plineSceneItem.x + (interactionState.x1 - interactionState.x2) * (1 - interactionState.zoom1);
                    plineSceneItem.y = plineSceneItem.y + (interactionState.y1 - interactionState.y2) * (1 - interactionState.zoom1);
                }
                MouseArea {
                    anchors.fill: parent
                }
            }
        }

        Rectangle {
            id: horizontalAxis
            x: parent.width / 2
            height: parent.height
            color: "black"
            width: 1 / interactionState.zoom2
        }
        Rectangle {
            id: verticalAxis
            y: parent.height / 2
            width: parent.width
            color: "black"
            height: 1 / interactionState.zoom2
        }
    }
}
