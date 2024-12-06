import Foundation

enum MpvPropertyID: UInt64 {
    case pause
}

class MpvController {
    var mpvPlayer: VideoLayer?

    var _pause = false
    var speed = 1.0
    var volumn = 50

    static let shared = MpvController()

    init() {}

    func control(videoLayer: VideoLayer) {
        self.mpvPlayer = videoLayer
    }

    func play() {
        self._pause = false
        mpvPlayer!.mpvSetPropertyAsync(property: "pause", value: _pause, id: MpvPropertyID.pause.rawValue)
    }

    func pause() {
        self._pause = true
        mpvPlayer!.mpvSetPropertyAsync(property: "pause", value: _pause, id: MpvPropertyID.pause.rawValue)
    }

    func toggle() {
        if _pause {
            play()
        } else {
            pause()
        }
    }

    func seek() {

    }

    func backward() {

    }

    func forward() {

    }

    func setVolumn() {

    }

    func setSpeed() {

    }

}
