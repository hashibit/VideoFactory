import SwiftUI

// 自定义音量 Slider 样式
struct VolumeSliderStyle: ViewModifier {
    let value: Binding<Double>
    let range: ClosedRange<Double>

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景轨道
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 3)

                // 已调节部分的轨道
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white)
                    .frame(width: CGFloat(value.wrappedValue) * geometry.size.width, height: 3)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let percentage = min(max(0, gesture.location.x / geometry.size.width), 1)
                        value.wrappedValue = percentage * (range.upperBound - range.lowerBound) + range.lowerBound
                    }
            )
        }
        .frame(height: 0)
    }
}

// 自定义进度 Slider 样式
struct ProgressSliderStyle: ViewModifier {
    let value: Binding<Double>
    let range: ClosedRange<Double>

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景轨道
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 4)

                // 已播放部分的轨道
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white)
                    .frame(width: CGFloat(value.wrappedValue) * geometry.size.width, height: 4)

                // 拖动条
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: 12)
                    .offset(x: CGFloat(value.wrappedValue) * (geometry.size.width - 2))
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let percentage = min(max(0, gesture.location.x / geometry.size.width), 1)
                        value.wrappedValue = percentage * (range.upperBound - range.lowerBound) + range.lowerBound
                    }
            )
        }
        .frame(height: 12)
    }
}

extension View {
    func volumeSliderStyle(value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        self.modifier(VolumeSliderStyle(value: value, range: range))
    }

    func progressSliderStyle(value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        self.modifier(ProgressSliderStyle(value: value, range: range))
    }
}
