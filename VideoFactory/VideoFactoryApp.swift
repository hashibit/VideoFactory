//
//  VideoFactoryApp.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/11/29.
//

import SwiftUI
import SwiftData

import UI
import Common

@main
struct VideoFactoryApp: App {
    var videoLayer = VideoLayer()
    var videoController = MpvController.shared

    @StateObject var subtitlesViewModel = SubtitlesViewModel()
    @State var isSelectingSubtitle: Bool = false
    @State var videoID: UUID?

    var body: some Scene {
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

                        Button("Update") {
                            subtitlesViewModel.fetchSubtitles(videoID: videoID)
                            isSelectingSubtitle = true
                        }

                        PlayerControlsView()
                            .padding(20)
                    }

                    if isSelectingSubtitle {
                        GeometryReader { geometry in
                            SubtitleSelectingView(
                                embededSubtitles: subtitlesViewModel.embededSubtitles,
                                externalSubtitles: subtitlesViewModel.externalSubtitles,
                                transcribeSubtitles: subtitlesViewModel.transcribeSubtitles,
                                translateSubtitles: subtitlesViewModel.translateSubtitles
                            )
                            .frame(width: 500, height: 300)
                            .position(
                                x: geometry.size.width/2,
                                y: geometry.size.height/2
                            )
                        }
                        .background(.gray.opacity(0.3))
                        .onTapGesture {
                            isSelectingSubtitle = false
                        }
                    }
                }

            }
            .background(.black)
            .onAppear {
                videoController.control(videoLayer: videoLayer)

                // let filepath = "/Users/jiechen/Downloads/scent-of-woman/out-of-order.mp4"
                let filepath = "/Users/jiechen/Downloads/mp4-subs/OUTPUT.mp4"
                videoLayer.tryLoadFile(filepath)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1280, height: 720)
    }
}
