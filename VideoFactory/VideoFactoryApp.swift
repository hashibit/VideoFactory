//
//  VideoFactoryApp.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/11/29.
//

import SwiftData
import SwiftUI

import Common
import Engine
import UI

@main
struct VideoFactoryApp: App {
    var videoLayer = VideoLayer()
    var videoController = MpvController.shared

    @State var videoID: UUID?
    @StateObject var subtitlesViewModel = SubtitlesViewModel()

    @State var showSubtitleSelecingView: Bool = false
    @State var showOpenFileDialog: Bool = false

    var videoStore = VideoStore.shared

    private func playVideoFile(_ filepath: String) {
        let videoModel: VideoModel
        // query database
        if let model = videoStore.query(filepath: filepath) {
            videoModel = model
        } else {
            videoModel = VideoModel()
            videoModel.id = videoStore.insert(video: videoModel)
        }
//        videoID = videoModel.id
//        subtitlesViewModel.fetchSubtitles(videoID: videoID)

        // start playing
        print("start playing \(filepath)")
        videoLayer.tryLoadFile(filepath)
    }

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
                            showSubtitleSelecingView = true
                        }

                        PlayerControlsView()
                            .padding(20)
                    }

                    if showSubtitleSelecingView {
                        GeometryReader { geometry in
                            SubtitleSelectingView(
                                embededSubtitles: subtitlesViewModel.embededSubtitles,
                                externalSubtitles: subtitlesViewModel.externalSubtitles,
                                transcribeSubtitles: subtitlesViewModel.transcribeSubtitles,
                                translateSubtitles: subtitlesViewModel.translateSubtitles,
                                selectedSubtitleID: subtitlesViewModel.selectedSubtitleID
                            )
                            .frame(width: 500, height: 300)
                            .position(
                                x: geometry.size.width / 2,
                                y: geometry.size.height / 2
                            )
                        }
                        .background(.gray.opacity(0.3))
                        .onTapGesture {
                            showSubtitleSelecingView = false
                        }
                    }
                }
            }
            .background(.black)
            .onAppear {
                videoController.control(videoLayer: videoLayer)

                // let filepath = "/Users/jiechen/Downloads/scent-of-woman/out-of-order.mp4"
                let filepath = "/Users/jiechen/Downloads/mp4-subs/OUTPUT.mp4"
                playVideoFile(filepath)
            }
            .fileImporter(
                isPresented: $showOpenFileDialog,
                allowedContentTypes: [.movie],
                allowsMultipleSelection: false
            ) {
                result in
                switch result {
                case let .success(file):
                    print("start playing \(file)")
                    playVideoFile(file.first!.absoluteString)
                case let .failure(error):
                    print(
                        "failed to open video file. \(error.localizedDescription)"
                    )
                }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1280, height: 720)
        .commands {
            FileMenuCommands(onOpenItemClicked: {
                print("open item clicked")
                showOpenFileDialog = true
            }, onQuitItemClicked: {
                print("quit item clicked")
            })
        }
        .onChange(of: videoID) { _, newValue in
            print("videoID change to \(String(describing: newValue))")
        }
    }
}

struct FileMenuCommands: Commands {
    var onOpenItemClicked: (() -> Void)?
    var onQuitItemClicked: (() -> Void)?

    var body: some Commands {
        // this remove New window option
        CommandGroup(replacing: .newItem) {}
        // this remove Close window option(I don't know why)
        CommandGroup(replacing: .saveItem) {}

        // this add ours options
        CommandGroup(after: CommandGroupPlacement.newItem) {
            Button("打开文件") {
                if let onOpenItemClicked { onOpenItemClicked() }
            }
            .keyboardShortcut("O", modifiers: [.command])

            Divider()

            Button("退出") {
                if let onQuitItemClicked { onQuitItemClicked() }
            }
            .keyboardShortcut("Q", modifiers: [.command])
        }
    }
}
