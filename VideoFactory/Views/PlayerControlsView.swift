import SwiftUI

struct PlayerControlsView: View {
    @State private var volume: Double = 0.5
    @State private var progress: Double = 0.0
    @State private var isPlaying = false
    @State private var currentTime = "00:00"
    @State private var totalTime = "00:00"

    var body: some View {
        VStack(spacing: 8) {
            // 第一行控制器
            HStack(spacing: 0) {
                // 左侧音量控制
                HStack(spacing: 8) {
                    ControlButton(systemName: "speaker.wave.2.fill") { }
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 80)
                        .volumeSliderStyle(value: $volume, range: 0...1)
                }
                .frame(width: 120)

                Spacer()

                // 中间播放控制
                HStack(spacing: 16) {
                    ControlButton(systemName: "backward.fill") {
                        // 后退逻辑
                    }
                    ControlButton(systemName: isPlaying ? "pause.fill" : "play.fill") {
                        isPlaying.toggle()
                    }
                    ControlButton(systemName: "forward.fill") {
                        // 前进逻辑
                    }
                }

                Spacer()

                // 右侧设置按钮
                HStack(spacing: 16) {
                    ControlButton(systemName: "photo") { }
                    ControlButton(systemName: "speaker.wave.3") { }
                    ControlButton(systemName: "text.bubble") { }
                }
                .frame(width: 120)
            }

            // 第二行控制器
            HStack(spacing: 8) {
                Text(currentTime)
                    .foregroundColor(.white)
                    .frame(width: 60)

                Rectangle()
                    .fill(.clear)
                    .progressSliderStyle(value: $progress, range: 0...1)

                Text(totalTime)
                    .foregroundColor(.white)
                    .frame(width: 60)
            }
        }
        .frame(width: 500)
        .padding(12)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(8)
        .padding(.bottom, 10)
    }
}