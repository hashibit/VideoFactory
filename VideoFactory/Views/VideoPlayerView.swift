import SwiftUI
import AVKit

struct VideoPlayerView: View {
    private let player: AVPlayer

    init() {
        // 这里使用一个测试视频URL，您可以替换成本地视频文件
        let testURL = Bundle.main.url(forResource: "test", withExtension: "mp4") ??
                      URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4")!
        self.player = AVPlayer(url: testURL)
    }

    var body: some View {
        VideoPlayer(player: player)
            .frame(width: 1280, height: 720)
            .onAppear {
                player.play()
            }
    }
}