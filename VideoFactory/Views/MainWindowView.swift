import SwiftUI

struct MainWindowView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("视频标题")
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .frame(width: 500)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)

                VideoPlayerView()

                PlayerControlsView()
            }
        }
    }
}

#Preview {
    MainWindowView()
}
