/*
 *  Configuration UI — General tab
 *
 *  The  cfg_  prefix on property aliases auto‑binds to the KConfig XT
 *  entries defined in  contents/config/main.xml.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: configPage

    property alias cfg_targetUrl:       urlField.text
    property alias cfg_targetWidth:     widthSpin.value
    property alias cfg_refreshInterval: refreshSpin.value

    Kirigami.FormLayout {
        anchors.fill: parent

        TextField {
            id: urlField
            Kirigami.FormData.label: "Target URL:"
            Layout.fillWidth: true
            placeholderText: "file:///path/to/file.html  or  http://localhost:8080"
            inputMethodHints: Qt.ImhUrlCharactersOnly
        }

        SpinBox {
            id: widthSpin
            Kirigami.FormData.label: "Widget width (px):"
            from: 100
            to: 2000
            stepSize: 50
            editable: true
        }

        SpinBox {
            id: refreshSpin
            Kirigami.FormData.label: "Auto-refresh (seconds):"
            from: 0
            to: 3600
            stepSize: 5
            editable: true
            textFromValue: function(v) { return v === 0 ? "Off" : v + "s" }
            valueFromText: function(t) { return parseInt(t) || 0 }
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: Kirigami.Theme.disabledTextColor
            text: "Examples:\n" +
                  "  • file:///home/user/status.html\n" +
                  "  • http://localhost:8080/dashboard\n" +
                  "  • https://example.com/widget\n\n" +
                  "Set auto-refresh to 0 to disable.  The page is rendered " +
                  "with a transparent background and auto‑scales to fit."
        }
    }
}
