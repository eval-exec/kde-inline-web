/*
 *  Inline HTML Panel View — Plasma 6 Plasmoid
 *
 *  Embeds a live WebEngineView directly inside a horizontal or vertical
 *  Plasma panel.  The widget resists the usual "collapse to icon" behaviour
 *  by setting  preferredRepresentation = fullRepresentation  and pushing
 *  switchWidth / switchHeight to -1 so the full content always renders inline.
 *
 *  -------------------------------------------------------------------
 *  ║  TARGET URL — change the line below to point at your HTML source ║
 *  -------------------------------------------------------------------
 *     Local file  : "file:///home/<you>/path/to/file.html"
 *     Dev server  : "http://localhost:8080"
 *     HTTPS site  : "https://example.com/status"
 *
 *  If you need per-user flexibility, un-comment the config section in
 *  PlasmoidItem and wire  Plasmoid.configuration.targetUrl  instead.
 */

import QtQuick
import QtQuick.Layouts
import QtWebEngine
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

// ===========================================================================
//  ROOT — PlasmoidItem (the mandatory Plasma 6 container)
// ===========================================================================
PlasmoidItem {
    id: root

    // ── Representation override ────────────────────────────────────────
    preferredRepresentation: fullRepresentation
    switchWidth:  -1
    switchHeight: -1

    // ── Context menu actions (shown by the panel containment) ──────────
    //  These appear in the panel's built-in right‑click menu, which
    //  renders outside the panel window (no clipping).
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: "Refresh"
            icon.name: "view-refresh"
            onTriggered: webView.reload()
        }
    ]

    // ── Plasma location constants (PlasmaCore.Types.Location values) ────
    //  TopEdge=1  BottomEdge=2  LeftEdge=3  RightEdge=4  Floating=0
    readonly property int locTopEdge:    1
    readonly property int locBottomEdge: 2

    // ── Panel‑aware layout binds ───────────────────────────────────────
    //  On a horizontal panel (top / bottom) the widget fills the panel
    //  height and the user drags the handle to control width.
    //  On a vertical panel (left / right) it fills the panel width and
    //  the user drags to control height.
    // ─────────────────────────────────────────────────────────────────────
    readonly property bool onHorizontalPanel: Plasmoid.location === locTopEdge  ||
                                              Plasmoid.location === locBottomEdge

    // Configurable width — fallback to 1000 when config key not yet saved
    readonly property int effWidth: Plasmoid.configuration.targetWidth > 0
        ? Plasmoid.configuration.targetWidth : 400

    // Panel layout: fill cross-axis, fixed width along the panel
    Layout.fillHeight:  onHorizontalPanel
    Layout.fillWidth:  !onHorizontalPanel

    Layout.minimumWidth:  effWidth
    Layout.preferredWidth: effWidth
    Layout.minimumHeight:  onHorizontalPanel ? 24   : effWidth
    Layout.preferredHeight: onHorizontalPanel ? 24   : effWidth

    // ╔══════════════════════════════════════════════════════════════════════╗
    // ║                       FULL REPRESENTATION                           ║
    // ╚══════════════════════════════════════════════════════════════════════╝
    fullRepresentation: Item {
        id: fullRep
        anchors.fill: parent

        WebEngineView {
            id: webView
            anchors {
                fill: parent
                leftMargin: favicon.width + 2
                rightMargin: 1
                topMargin: 1
                bottomMargin: 1
            }

            // ─────────────────────────────────────────────────────────
            //  Target URL — set via  right-click → Configure…  (or
            //  edit the default in  contents/config/main.xml).
            //
            //  Examples:
            //    "file:///home/you/my-status.html"
            //    "http://localhost:8080/dashboard"
            //    "https://example.com/mini-widget"
            //
            //  Note: some sites (google.com, etc.) block being embedded
            //  in frames — use a local file or your own server instead.
            // ─────────────────────────────────────────────────────────
            url: Plasmoid.configuration.targetUrl

            // ── Transparent background ────────────────────────────────
            backgroundColor: "transparent"

            // ── Auto-scale the page to fit the widget width ───────────
            //  Sets the initial zoom so a ~1024 px page fits the panel.
            //  The HTML page can also use  <meta name="viewport" …>
            //  for responsive scaling.
            zoomFactor: Math.max(0.25, Math.min(1.0, fullRep.width / 1024))

            // ── Settings ──────────────────────────────────────────────
            settings.localContentCanAccessRemoteUrls: true
            settings.javascriptEnabled:              true
            settings.errorPageEnabled:               false

            // ── Scroll policy — panel widgets rarely need scrollbars ──
            settings.showScrollBars: false

            // ── Loading overlay ───────────────────────────────────────
            onLoadingChanged: load => {
                if (load.status === WebEngineView.LoadSucceededStatus) {
                    // Inject a tiny helper to force a transparent
                    // document background when the page author forgot.
                    runJavaScript(`
                        (function(){
                            var s = document.body.style;
                            if (!s.backgroundColor || s.backgroundColor==='' ||
                                s.backgroundColor==='rgba(0, 0, 0, 0)' ||
                                s.backgroundColor==='white' || s.backgroundColor==='#ffffff' ||
                                s.backgroundColor==='#fff'){
                                s.backgroundColor='transparent';
                            }
                            var hs = document.documentElement.style;
                            if (!hs.backgroundColor || hs.backgroundColor==='' ||
                                hs.backgroundColor==='rgba(0, 0, 0, 0)' ||
                                hs.backgroundColor==='white' || hs.backgroundColor==='#ffffff' ||
                                hs.backgroundColor==='#fff'){
                                hs.backgroundColor='transparent';
                            }
                        })();
                    `)
                }
            }
        }

        // ── Favicon anchor ──────────────────────────────────────────
        //  Sits outside the WebEngineView so right‑clicks propagate
        //  to the containment (which shows the proper popup menu
        //  with Refresh + Configure, unclipped).  Left‑click refreshes.
        Rectangle {
            id: favicon
            anchors { left: parent.left; top: parent.top; margins: 1 }
            width: 16; height: 16
            radius: 3
            color: favMouse.containsMouse
                ? Qt.rgba(1,1,1,0.2) : Qt.rgba(1,1,1,0.05)

            // Real favicon from the loaded page
            Image {
                anchors { fill: parent; margins: 2 }
                source: webView.icon
                visible: webView.icon.toString() !== ""
                asynchronous: true
            }
            // Fallback globe when no favicon yet
            Text {
                anchors.centerIn: parent
                text: "🌐"
                font.pixelSize: 10
                visible: webView.icon.toString() === ""
            }

            MouseArea {
                id: favMouse
                anchors.fill: parent
                // Only accept left‑click — right‑click propagates to
                // the containment for the popup menu.
                acceptedButtons: Qt.LeftButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: webView.reload()
            }
        }

        // ── Refresh button (visible on hover) ───────────────────────
        Rectangle {
            anchors { right: parent.right; bottom: parent.bottom; margins: 2 }
            width: 16; height: 16
            radius: 3
            color: refreshMouse.containsMouse
                ? Qt.rgba(1,1,1,0.2) : Qt.rgba(1,1,1,0.05)
            visible: refreshMouse.containsMouse || refreshTimer.running

            Text {
                anchors.centerIn: parent
                text: "↻"
                color: "white"
                font.pixelSize: 12
            }

            MouseArea {
                id: refreshMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: webView.reload()
            }
        }

        // ── Auto‑refresh timer ──────────────────────────────────────
        //  Reloads the page at the configured interval (0 = disabled).
        Timer {
            id: refreshTimer
            interval: Math.max(0, Plasmoid.configuration.refreshInterval) * 1000
            repeat: true
            running: Plasmoid.configuration.refreshInterval > 0
            onTriggered: webView.reload()
        }
    }

    // ╔══════════════════════════════════════════════════════════════════════╗
    // ║                     COMPACT REPRESENTATION                           ║
    // ║  Required by the API but never shown in practice because of the      ║
    // ║  preferredRepresentation override above.  Kept as a minimal stub.    ║
    // ╚══════════════════════════════════════════════════════════════════════╝
    compactRepresentation: Item {
        anchors.fill: parent

        // In the unlikely event the panel forces compact mode, show a
        // tiny “HTML” label instead of a blank box.
        Rectangle {
            anchors.centerIn: parent
            width:  parent.width  - 4
            height: parent.height - 4
            radius: 3
            color: "transparent"
            border { color: Qt.rgba(1, 1, 1, 0.3); width: 1 }

            Text {
                anchors.centerIn: parent
                text:      "◈"
                color:     "white"
                font.pixelSize: parent.height * 0.6
            }
        }
    }
}
