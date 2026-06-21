/*
 *  Config model — tells Plasma which configuration tabs exist and
 *  which QML files render them.  Without this file the "Configure…"
 *  entry never appears in the right‑click menu.
 */

import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "configure"
        source: "configGeneral.qml"
    }
}
