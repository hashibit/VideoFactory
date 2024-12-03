//
//  OpenGLVideoViewRepresentable.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/12/2.
//

import SwiftUI

struct OpenGLVideoViewRepresentable: NSViewRepresentable {
    let videoLayer: CALayer
    
    func makeNSView(context: Context) -> some NSView {
        return OpenGLVideoView(videoLayer: videoLayer)
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
    }
}
