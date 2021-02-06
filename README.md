# Icon Font Viewer

Simple icon font viewer written in Qt 5 / QML.

WIP: Currently loads and displays [IcoMoon](https://icomoon.io/) fonts. Fonts
need to be saved to disk and include `selection.json` file. Font paths are
hardcoded in the QML file for now. You need to download the fonts by yourself.

## Prerequisites

Requires Qt 5.15

Set env variable `QML_XHR_ALLOW_FILE_READ=1`

## Run

```
qmlscene icomoon-viewer.qml
```
