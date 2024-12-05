//
//  VideoFactoryApp.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/11/29.
//

import SwiftUI
import SwiftData

@main
struct VideoFactoryApp: App {
//    @State
//    var isResizing: Bool = false
    
    var videoLayer = VideoLayer()
    
    // @Environment(\.modelContext)
    // var modelContext: ModelContext
    
    var body: some Scene {
        let dbPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("vpf.db")
        let configuration = ModelConfiguration(url: dbPath)
        let container = try! ModelContainer(for: VideoModel.self, SubtitleModel.self, configurations: configuration)
        
        return WindowGroup {
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
            .background(.black)
            .onAppear {
                let filepath = "/Users/jiechen/Downloads/scent-of-woman/out-of-order.mp4"
                videoLayer.tryLoadFile(filepath: filepath)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1280, height: 720)
        .environment(\.modelContext, container.mainContext)
    }
}
