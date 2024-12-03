//
//  VideoFactoryApp.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/11/29.
//

import SwiftUI

@main
struct VideoFactoryApp: App {
    @State
    var isResizing: Bool = false
    
    var videoLayer = VideoLayer()
    
    var body: some Scene {
        WindowGroup {
            ResizableWindow(isResizing: $isResizing) {
                VideoView {
                    ZStack {
                        OpenGLVideoViewRepresentable(videoLayer: videoLayer)
                        
                        VStack {
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
                .background(.blue)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1280, height: 720)
    }
}
