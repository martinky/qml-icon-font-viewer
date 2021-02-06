import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/* TODO:

  - tool bar
    + prev, next font
    + zoom in, out
    + font info - name, number of icons, base grid size
    - open file dialog - browse for font metadata json file
    - open font from web - predefined font sites
    - view mode - icons only, icons and info
    - quick search
      + by icon name
      + by icon tags
      - ligature aliases
    - change preview color (background, button, icon)
  - show icon info on hover
  - copy icon code to clipboard

*/

ApplicationWindow {
    id: app
    width: 900+25+10
    height: 720

    title: "Icon Font Viewer"

    color: "#404040"

    header: ToolBar {
        background: Rectangle {
            color: "#484848"
        }
        RowLayout {
            anchors.fill: parent
            spacing: 2
            ToolButton {
                text: "<"
                action: actPrevFont
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: "Previous Font (Ctrl+Left)"
            }
            ToolButton {
                text: ">"
                action: actNextFont
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: "Next Font (Ctrl+Right)"
            }
            TextField {
                id: editSeach
                placeholderText: "Search"
                rightPadding: 50
                font.pixelSize: 16
                Button {
                    text: "x"
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 4
                    width: 42
                    enabled: parent.text.length > 0
                    onClicked: parent.clear()
                }
            }
            ToolButton {
                text: "-"
                action: actZoomOut
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: "Zoom Out (Ctrl+Minus, Ctrl+Shift+Minus)"
            }
            ToolButton {
                text: "+"
                action: actZoomIn
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: "Zoom In (Ctrl+Plus, Ctrl+Shift+Plus)"
            }
            ToolButton {
                text: "Reset Zoom"
                action: actZoomReset
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: "Reset Zoom (Ctrl+0)"
            }
            Item {
                Layout.fillWidth: true
            }
        }
    }

    footer: ToolBar {
        background: Rectangle {
            color: "#484848"
        }
        RowLayout {
            anchors.fill: parent
            spacing: 2
            Label {
                text: "%1 - %2".arg(theFont.name).arg(theFont.source)
                Layout.fillWidth: true
                font.pixelSize: 14
                color: "#dddddd"
                padding: 4
            }
            Label {
                text: "%1 px".arg(app.gridSize)
                font.pixelSize: 14
                color: "#dddddd"
                padding: 4
            }
            Label {
                text: "%1 icons".arg(listModel.count)
                font.pixelSize: 14
                color: "#dddddd"
                padding: 4
            }
        }
    }

    property variant fontUrls : [
        "./icomoon/",
        "./icomoon-brankic/",
        "./icomoon-entypo/",
        "./icomoon-feather/",
        "./icomoon-font-awesome/",
        "./icomoon-free/",
        "./icomoon-ultimate/",
        "./icomoon-google-material/"
    ]

    property int fontUrlIndex : 0
    property url fontBasePath : fontUrls[fontUrlIndex]

    property int gridSize: 12
    property int previewSize : 24
    property int numIcons: 0

    property alias filter: editSeach.text

    ListModel { id: listModel }
    ListModel { id: filteredModel }

    FontLoader {
        id: theFont
    }

    Item {
        anchors.fill: parent

        Flickable {
            anchors.fill: parent
            anchors.margins: 5
            contentWidth: flow.childrenRect.width
            contentHeight: flow.childrenRect.height
            flickableDirection: Flickable.VerticalFlick
            ScrollIndicator.vertical: ScrollIndicator { }
            clip: true

            Flow {
                id: flow
                width: parent.parent.width
                spacing: 5

                Repeater {
                    id: repeater
                    model: filter.length > 0 ? filteredModel : listModel

                    delegate: Rectangle {
                        id: dlg
                        width: Math.max(80, previewSize + 10)
                        height: Math.max(50, previewSize + 10)
                        color: "#f0f0f0"
                        property variant myModel : model
                        Item {
                            anchors.fill: parent
                            anchors.margins: 5
                            //spacing: 10
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    colIcon.opacity = 0.1
                                    colInfo.opacity = 1
                                }
                                onExited: {
                                    colIcon.opacity = 1
                                    colInfo.opacity = 0
                                }
                            }
                            Text {
                                id: colIcon
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "#404040"
                                font.family: theFont.name
                                font.pixelSize: previewSize
                                renderType: Text.NativeRendering
                                text: String.fromCharCode(dlg.myModel.code);
                                opacity: 1
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }
                            Column {
                                id: colInfo
                                anchors.fill: parent
                                opacity: 0
                                Text { text: dlg.myModel.name; renderType: Text.NativeRendering }
                                Grid {
                                    rows: 2
                                    columns: 3
                                    Text { text: "DEC"; renderType: Text.NativeRendering }
                                    Item { width: 10; height: 1 }
                                    Text { text: dlg.myModel.code; renderType: Text.NativeRendering }
                                    Text { text: "HEX"; renderType: Text.NativeRendering }
                                    Item { width: 10; height: 1 }
                                    Text { text: dlg.myModel.code.toString(16).toUpperCase(); renderType: Text.NativeRendering }
                                }
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }
                        }
                    }
                } // Repeater
            } // Flow
        } // Flickable
    } // Item


    Rectangle {
        id: msg
        anchors.centerIn: parent
        width: 280
        height: 80
        color: "#C0C0C0"
        radius: 7
        opacity: 0

        Text {
            anchors.centerIn: parent
            font.pixelSize: 24
            text: "Preview Size: " + previewSize + " px"
        }

        SequentialAnimation {
            id: msgAnim
            PropertyAction { target: msg; property: "opacity"; value: 1 }
            PauseAnimation { duration: 750 }
            NumberAnimation { target: msg; property: "opacity"; to: 0; duration: 500; easing.type: Easing.InQuad }
        }
    }

    Action {
        id: actNextFont
        shortcut: "Ctrl+Right"
        onTriggered: function () {
            let nextUrlIndex = fontUrlIndex + 1
            if (nextUrlIndex >= fontUrls.length) nextUrlIndex = 0
            fontUrlIndex = nextUrlIndex
        }
    }

    Action {
        id: actPrevFont
        shortcut: "Ctrl+Left"
        onTriggered: function () {
            let nextUrlIndex = fontUrlIndex - 1
            if (nextUrlIndex < 0) nextUrlIndex = fontUrls.length - 1
            fontUrlIndex = nextUrlIndex
        }
    }

    Action {
        id: actZoomIn
        shortcut: "Ctrl++"
        onTriggered: function () {
            previewSize = Math.min(Math.floor((previewSize+gridSize) / gridSize) * gridSize, 1024)
            msgAnim.restart()
        }
    }

    Action {
        shortcut: "Ctrl+Shift++"
        id: actZoomInSingle
        onTriggered: function () {
            previewSize = Math.min(previewSize + 1, 1024)
            msgAnim.restart()
        }
    }

    Action {
        id: actZoomOut
        shortcut: "Ctrl+-"
        onTriggered: function () {
            previewSize = Math.max(Math.ceil((previewSize-gridSize) / gridSize) * gridSize, 1)
            msgAnim.restart()
        }
    }

    Action {
        id: actZoomOutSingle
        shortcut: "Ctrl+Shift+-"
        onTriggered: function () {
            previewSize = Math.max(previewSize - 1, 1)
            msgAnim.restart()
        }
    }

    Action {
        id: actZoomReset
        shortcut: "Ctrl+0"
        onTriggered: function () {
            previewSize = gridSize
            msgAnim.restart()
        }
    }

    onFontBasePathChanged: function () {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function () {
            if (doc.readyState === XMLHttpRequest.DONE) {
                console.log("Load complete.");
                //console.log(doc.responseText);

                var jsonModel = JSON.parse(doc.responseText)
                var fontName = jsonModel.preferences.fontPref.metadata.fontFamily
                var fontPath = fontBasePath + "fonts/" + fontName + ".ttf"
                theFont.source = fontPath

                console.log("Glyph codes for QML icon theme: " + fontName);

                function capitalize(name) {
                    var out = ""
                    var capital = true
                    for (var i = 0; i < name.length; i++) {
                        var c = name.charAt(i)
                        if (c === '-' || c === '_') {
                            capital = true
                        } else {
                            if (capital) {
                                out = out + c.toUpperCase()
                                capital = false
                            } else {
                                out = out + c
                            }
                        }
                    }
                    return out
                }

                listModel.clear()
                for (var index in jsonModel.icons) {
                    const jsonIcon = jsonModel.icons[index]
                    const iconName = jsonIcon.properties.name
                    const iconCode = jsonIcon.properties.code
                    const iconTags = jsonIcon.icon.tags
                    listModel.append({
                                         "name": iconName,
                                         "code": iconCode,
                                         "tags": { t: iconTags }
                                     })
                    console.log("property string icon" + capitalize(iconName) + ": \"\\u" + iconCode.toString(16).toUpperCase() + "\"");
                }

                gridSize = jsonModel.icons[0].icon.grid
                previewSize = gridSize
            }
        }

        var fontJsonPath = Qt.resolvedUrl(fontBasePath + "selection.json")
        doc.open("GET", fontJsonPath);
        doc.send();
    }

    onFilterChanged: {
        filteredModel.clear()
        if (filter.length === 0) return
        for (var i = 0; i < listModel.count; i++) {
            const item = listModel.get(i)
            if (item.name.includes(filter) || item.tags.t.some((v) => v.includes(filter))) {
                filteredModel.append(item)
            }
        }
    }

}
