import Foundation

class MpvController {
    var mpvPlayer: VideoLayer?

    var _pause = false
    var speed = 1.0
    var volume = 50

    static let shared = MpvController()

    init() {}

    func control(videoLayer: VideoLayer) {
        mpvPlayer = videoLayer
    }

    func play() {
        self._pause = false
        mpvPlayer!.mpvSetPropertyAsync(property: "pause", value: _pause, id: AsyncID.pause.rawValue)
    }

    func pause() {
        self._pause = true
        mpvPlayer!.mpvSetPropertyAsync(property: "pause", value: _pause, id: AsyncID.pause.rawValue)
    }

    func toggle() {
        _pause ? play() : pause()
    }

    func seek() {
    }

    func backward() {

    }

    func forward() {

    }

    func setVolumn() {

    }

    func getVolumn() {
        guard let mpvPlayer = mpvPlayer else {
            print("mpv player is not ready yet.")
            return
        }
        if let volume: Double = mpvPlayer.mpvGetProperty(property: MpvProperty.volume.rawValue) {
            print("current volumn is: \(volume)")
        }
        if let trackList: [[String: Any]] = mpvPlayer.mpvGetProperty(property: MpvProperty.trackList.rawValue) {
            print("current trackList is: \(trackList)")
        }

        let rand = Double.random(in: 0..<100)
        mpvPlayer.mpvSetProperty(property: MpvProperty.volume.rawValue, value: rand)

        if let volume: Double = mpvPlayer.mpvGetProperty(property: MpvProperty.volume.rawValue) {
            print("current volumn is: \(volume)")
        }
    }

    func setSpeed() {

    }

}
