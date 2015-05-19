import QtQuick 2.2
import Com.Deepin.DeepinMovie 1.0

import "../sources/ui_utils.js" as UIUtils

Item {
    id: root

    property int pieceCount: 15

    property bool __running: false
    property int __lastPiece: 0
    property int __lastPieceIndex: -1
    property var __stickers: []

    property string stickersDir: "/tmp/deepin-movie-poster"

    function _getPiece(index) {
        var durationAva = player.duration / pieceCount
        var start = index * durationAva

        return start + durationAva * Math.random()
    }

    function _takeShot() {
        player.videoCapture.captureDir = stickersDir
        player.videoCapture.capture()
    }

    function reset() {
        __running = false
        __lastPiece = 0
        __lastPieceIndex = -1
        __stickers = []
    }

    function start() {
        hideControls()

        __running = true
        // player.pause()
        _next()
    }

    function _next() {
        __lastPieceIndex++
        if (__lastPieceIndex < pieceCount) {
            var piece = _getPiece(__lastPieceIndex)
            __lastPiece = piece
            player.seek(piece)
        } else {
            poster_generator.title = _utils.getTitleFromUrl(player.sourceString)
            poster_generator.duration = UIUtils.formatTime(player.duration)
            poster_generator.resolution = "%1x%2".arg(player.resolution.width).arg(player.resolution.height)
            poster_generator.size = UIUtils.formatSize(player.storageSize)

            var image = poster_generator.generate(__stickers)
            picture_preview.picture = image
            picture_preview.show()
        }
    }

    PosterGenerator { id: poster_generator }

    Connections {
        target: player
        onSeekFinished: {
            if (__running) {
                root._takeShot()
            }
        }
    }

    Connections {
        target: player.videoCapture
        onSaved: {
            __stickers.push([UIUtils.formatTime(__lastPiece), path])
            root._next()
        }
    }
}