import SwiftUI

struct MainWindowView: View {
    @State
    var windowIsResizing: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("视频标题")
                    .foregroundColor(.white)
                    .padding(10)
                    .frame(width: 500)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(8)

                Spacer()

                PlayerControlsView()
                    .padding(20)
            }
        }
    }
}

#Preview {
    MainWindowView()
}
