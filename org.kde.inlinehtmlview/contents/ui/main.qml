/*
 *  Inline HTML Panel View — Plasma 6 Plasmoid
 *
 *  WebEngineView inline in the panel (always visible).
 *  TapHandler catches left‑click → opens full popup.
 *  Right‑click 🌐 → containment menu.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // ── In panel: show inline, but popup on click ───────────────────
    readonly property bool inPanel: [PlasmaCore.Types.TopEdge, PlasmaCore.Types.RightEdge,
                                      PlasmaCore.Types.BottomEdge, PlasmaCore.Types.LeftEdge]
                                      .includes(Plasmoid.location)

    preferredRepresentation: inPanel ? compactRepresentation : fullRepresentation
    switchWidth:  inPanel ? Number.POSITIVE_INFINITY : Kirigami.Units.gridUnit * 16
    switchHeight: inPanel ? Number.POSITIVE_INFINITY : Kirigami.Units.gridUnit * 23

    // ── Context menu ────────────────────────────────────────────────
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: "Refresh"
            icon.name: "view-refresh"
            onTriggered: { if (root.doRefresh) root.doRefresh() }
        }
    ]
    property var doRefresh: null

    // ── Location ─────────────────────────────────────────────────────
    readonly property int locTopEdge:    1
    readonly property int locBottomEdge: 2
    readonly property bool onHorizontalPanel: Plasmoid.location === locTopEdge  ||
                                              Plasmoid.location === locBottomEdge

    // ── Shared URL (synced between compact and popup) ──────────────
    property url currentUrl: Plasmoid.configuration.targetUrl

    // Sync: when popup closes, copy its URL back to the inline view
    onExpandedChanged: {
        if (!expanded && popupWebView.url.toString() !== currentUrl.toString()) {
            currentUrl = popupWebView.url
        }
    }

    // ── Config ──────────────────────────────────────────────────────
    readonly property int effWidth: Plasmoid.configuration.targetWidth > 0
        ? Plasmoid.configuration.targetWidth : 400

    Layout.fillHeight:  onHorizontalPanel
    Layout.fillWidth:  !onHorizontalPanel
    Layout.minimumWidth:  effWidth
    Layout.preferredWidth: effWidth

    // ╔══════════════════════════════════════════════════════════════════╗
    // ║       COMPACT — inline WebEngineView + TapHandler              ║
    // ╚══════════════════════════════════════════════════════════════════╝
    compactRepresentation: Item {
        id: compactRoot
        anchors.fill: parent
        Layout.fillHeight:  root.onHorizontalPanel
        Layout.fillWidth:  !root.onHorizontalPanel
        Layout.minimumWidth:  root.effWidth
        Layout.preferredWidth: root.effWidth

        Component.onCompleted: {
            root.doRefresh = function() { compactWebView.reload() }
        }

        WebEngineView {
            id: compactWebView
            anchors {
                fill: parent
                leftMargin:  favicon.width + 2
                rightMargin: 1; topMargin: 1; bottomMargin: 1
            }
            url: root.currentUrl
            backgroundColor: "transparent"
            zoomFactor: Math.max(0.15, Math.min(1.0, compactRoot.width / 1024))

            settings.localContentCanAccessRemoteUrls: true
            settings.javascriptEnabled:              true
            settings.errorPageEnabled:               false
            settings.showScrollBars:                 false

        }

        // Favicon (click to toggle popup)
        Rectangle {
            id: favicon
            anchors { left: parent.left; top: parent.top; margins: 1 }
            width: 16; height: 16; radius: 3
            color: favMouse.containsMouse ? Qt.rgba(1,1,1,0.2) : "transparent"

            Image {
                anchors { fill: parent; margins: 2 }
                source: compactWebView.icon
                visible: compactWebView.icon.toString() !== ""
                asynchronous: true
            }
            Text {
                anchors.centerIn: parent
                text: "🌐"; font.pixelSize: 10
                visible: compactWebView.icon.toString() === ""
            }
            MouseArea {
                id: favMouse
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.expanded = !root.expanded
            }
        }

        // Auto‑refresh
        Timer {
            interval: Math.max(0, Plasmoid.configuration.refreshInterval) * 1000
            repeat: true
            running: Plasmoid.configuration.refreshInterval > 0
            onTriggered: compactWebView.reload()
        }
    }

    // ╔══════════════════════════════════════════════════════════════════╗
    // ║       FULL — interactive WebEngineView popup                   ║
    // ╚══════════════════════════════════════════════════════════════════╝
    fullRepresentation: Item {
        id: fullRoot
        implicitWidth:  Math.max(root.effWidth + 100, 700)
        implicitHeight: 500
        Layout.minimumWidth:  400
        Layout.preferredWidth: Math.max(root.effWidth + 100, 700)
        Layout.minimumHeight: 300

        WebEngineView {
            id: popupWebView
            anchors { fill: parent; margins: 2 }
            url: root.currentUrl
            backgroundColor: "white"
            settings {
                localContentCanAccessRemoteUrls: true
                javascriptEnabled: true
                errorPageEnabled: false
                showScrollBars: true
            }
        }
    }
}
