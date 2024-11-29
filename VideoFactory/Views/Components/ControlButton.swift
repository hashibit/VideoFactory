import SwiftUI
import AppKit

struct ControlButton: View {
    let systemName: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .frame(width: 20, height: 20)
                .foregroundStyle(.white)
                .contentShape(Rectangle())
                .opacity(isHovered ? 0.7 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

#Preview {
    VStack {
        ControlButton(systemName: "speaker.wave.3") { }.background(.black)
    }.frame(width: 100, height: 100)
}
