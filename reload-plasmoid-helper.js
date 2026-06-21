/*
 *  Plasma Desktop Script — remove + re-add the Inline HTML Panel View
 *  widget, forcing a fresh QML instance from disk.
 *
 *  Called by reload-plasmoid via:
 *    qdbus org.kde.plasmashell /PlasmaShell
 *          org.kde.PlasmaShell.evaluateScript "$(cat this-file.js)"
 */

var PLUGIN = "org.kde.inlinehtmlview";
var removed = 0;
var added   = 0;
var targetPanels = [];

var allPanels = panels();
print("Found " + allPanels.length + " panel(s)");

// 1 — find panels with our widget and remove from each
for (var i = 0; i < allPanels.length; i++) {
    var panel = allPanels[i];
    var widgets = panel.widgets(PLUGIN);

    for (var j = 0; j < widgets.length; j++) {
        var w = widgets[j];
        print("  Removing " + PLUGIN + " (id=" + w.id + ") from panel " + panel.id);
        w.remove();
        removed++;
        targetPanels.push(panel);
    }
}

// 2 — re-add to the same panels
for (var k = 0; k < targetPanels.length; k++) {
    var p = targetPanels[k];
    var newWidget = p.addWidget(PLUGIN);
    print("  Added " + PLUGIN + " (id=" + newWidget.id + ") to panel " + p.id);
    added++;
}

if (removed === 0) {
    print("Widget " + PLUGIN + " not found on any panel — nothing to reload");
} else {
    print("Done: removed " + removed + ", added " + added);
}
