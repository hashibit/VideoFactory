//
//  OpenGLVideoView.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/12/2.
//

import SwiftUI

class OpenGLVideoView: NSView {
    var videoLayer: CALayer

    init(videoLayer: CALayer) {
        self.videoLayer = videoLayer
        super.init(frame: .zero)

        self.wantsLayer = true
        self.layer = videoLayer
        // self.layer?.addSublayer(videoLayer)

        // 设置自动调整大小
        self.autoresizingMask = [.width, .height]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        // 确保 video layer 填满整个视图
        // videoLayer.frame = self.bounds
    }
}
