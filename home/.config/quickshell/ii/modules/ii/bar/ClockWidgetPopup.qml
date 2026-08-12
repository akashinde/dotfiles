import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.ii.sidebarRight
import qs.services
import QtQuick
import Quickshell
import Quickshell.Wayland

LazyLoader {
    id: root
    property Item anchorItem
    property bool open: false
    signal closeRequested()

    active: root.open && root.anchorItem !== null

    component: PanelWindow {
        id: popupWindow
        color: "transparent"
        exclusiveZone: 0
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: popupBackground.implicitWidth + Appearance.sizes.elevationMargin * 2
        implicitHeight: popupBackground.implicitHeight + Appearance.sizes.elevationMargin * 2
        WlrLayershell.namespace: "quickshell:clockCalendar"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.layer: WlrLayer.Overlay

        anchors {
            top: true
            left: true
        }

        margins {
            left: {
                const mapped = root.QsWindow?.mapFromItem(
                    root.anchorItem,
                    (root.anchorItem.width - popupBackground.implicitWidth) / 2,
                    0
                );
                const desired = mapped?.x ?? 0;
                const screenWidth = root.QsWindow?.screen?.width ?? (desired + popupBackground.implicitWidth);
                const maxX = screenWidth - popupBackground.implicitWidth - Appearance.sizes.hyprlandGapsOut;
                return Math.max(Appearance.sizes.hyprlandGapsOut, Math.min(desired, maxX));
            }
            top: Math.max(0, Appearance.sizes.barHeight - Appearance.sizes.elevationMargin + 2)
        }

        mask: Region {
            item: popupBackground
        }

        Component.onCompleted: {
            GlobalFocusGrab.addDismissable(popupWindow);
            bottomWidgetGroup.forceActiveFocus();
        }

        Component.onDestruction: {
            GlobalFocusGrab.removeDismissable(popupWindow);
        }

        Connections {
            target: GlobalFocusGrab
            function onDismissed() {
                root.closeRequested();
            }
        }

        StyledRectangularShadow {
            target: popupBackground
        }

        Rectangle {
            id: popupBackground
            readonly property real horizontalPadding: 8
            readonly property real topPadding: 0
            readonly property real bottomPadding: 8
            anchors {
                fill: parent
                margins: Appearance.sizes.elevationMargin
            }
            implicitWidth: bottomWidgetGroup.width + horizontalPadding * 2
            implicitHeight: bottomWidgetGroup.height + topPadding + bottomPadding
            color: Appearance.m3colors.m3surfaceContainer
            radius: Appearance.rounding.small
            border.width: 1
            border.color: Appearance.colors.colLayer0Border

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    root.closeRequested();
                    event.accepted = true;
                }
            }

            BottomWidgetGroup {
                id: bottomWidgetGroup
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    topMargin: popupBackground.topPadding
                }
                width: Appearance.sizes.sidebarWidth
                height: implicitHeight
                collapsed: false
                showCollapseControls: false
                focus: true
            }
        }
    }
}
