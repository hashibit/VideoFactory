import AppKit
import SwiftUI

public struct ControlButton: View {
    public let systemName: String
    public let action: () -> Void

    @State public var isHovered = false

    // 添加 public 初始化器
    public init(systemName: String, action: @escaping () -> Void) {
        self.systemName = systemName
        self.action = action
    }

    public var body: some View {
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
        ControlButton(systemName: "speaker.wave.3") {}.background(.black)
    }.frame(width: 100, height: 100)
}
