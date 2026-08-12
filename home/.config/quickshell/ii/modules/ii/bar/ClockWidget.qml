import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool showDate: Config.options.bar.verbose
    property bool calendarOpen: false
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4

        StyledText {
            font.pixelSize: Appearance.font.pixelSize.large
            color: Appearance.colors.colOnLayer1
            text: DateTime.time
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: "•"
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: DateTime.longDate
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onPressed: mouse => {
            mouse.accepted = true;
        }

        onClicked: mouse => {
            if (mouse.button !== Qt.LeftButton)
                return;

            root.calendarOpen = !root.calendarOpen;
            if (root.calendarOpen)
                GlobalStates.sidebarRightOpen = false;
            mouse.accepted = true;
        }

        ClockWidgetPopup {
            anchorItem: mouseArea
            open: root.calendarOpen
            onCloseRequested: root.calendarOpen = false
        }
    }
}
