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

    property alias cfg_targetUrl:   urlField.text
    property alias cfg_targetWidth: widthSpin.value

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

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            color: Kirigami.Theme.disabledTextColor
            text: "Examples:\n" +
                  "  • file:///home/user/status.html\n" +
                  "  • http://localhost:8080/dashboard\n" +
                  "  • https://example.com/widget\n\n" +
                  "The page is rendered with a transparent background " +
                  "and auto‑scales to fit the widget width."
        }
    }
}
