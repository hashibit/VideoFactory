//
//  VideoFactoryApp.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/11/29.
//

import SwiftData
import SwiftUI

import Engine
import Common
import UI

@main
struct VideoFactoryApp: App {
    var videoLayer = VideoLayer()
    var videoController = MpvController.shared

    @State var videoID: UUID?
    @State var videoFilepath: String?
    @State var subtitlesViewModel = SubtitlesViewModel()

    @State var showSubtitleSelecingView: Bool = false
    @State var showOpenFileDialog: Bool = false

    var videoStore = VideoStore.shared

    private func playVideoFile(_ filepath: String) {
        guard let videoModel = videoStore.findOrCreateVideoModel(filepath) else {
            print("failed to find video model at filepath: \(filepath), not ")
            return
        }

        videoID = videoModel.id
        videoFilepath = videoModel.filepath
        subtitlesViewModel.fetchSubtitlesFromDB(videoID: videoID!)
        videoLayer.registerEventCallback(type: .fileLoaded, handler: { _ in
            if let trackList: [[String: Any]] = videoLayer.mpvGetProperty(property: MpvProperty.trackList.rawValue) {
                print("current trackList is: \(trackList)")
                let subtitleTracks = trackList.filter { $0["type"] as? String == "sub" }
                print("filtered subtitleTracks is: \(subtitleTracks)")
                Task { @MainActor in
                    subtitlesViewModel.loadSubtitlesFromTracks(videoID!, subtitleTracks)
                }
            }
        })

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
//                            showSubtitleSelecingView = true

                            // 获取缓存目录路径
                            let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                            // 构建完整的文件路径
                            let pcmPath = cacheDir.appendingPathComponent("output_audio.wav")
                            Engine.shared
                                .extractAudioFromVideo(
                                    videoFilepath!,
                                    pcmPath.path()
                                )
                        }

                        PlayerControlsView()
                            .padding(20)
                    }

                    if showSubtitleSelecingView {
                        GeometryReader { geometry in
                            SubtitleSelectingView(
                                embededSubtitles: $subtitlesViewModel.embededSubtitles,
                                externalSubtitles: $subtitlesViewModel.externalSubtitles,
                                transcribeSubtitles: $subtitlesViewModel.transcribeSubtitles,
                                translateSubtitles: $subtitlesViewModel.translateSubtitles,
                                selectedSubtitleID: $subtitlesViewModel.selectedSubtitleID,
                                onInsertOrUpdateSubtitle: { subtitle in
                                    if let videoID = videoID {
                                        subtitle.movieID = videoID
                                        subtitlesViewModel.updateOrInsertSubtitle(subtitle)
                                    }
                                }
                            )
                            .frame(width: 800, height: 600)
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
            .onChange(of: subtitlesViewModel.embededSubtitles) { _, newValue in
                print("embeded subtitles change to \(newValue)")
            }
            .background(.black)
            .onAppear {
                videoController.control(videoLayer: videoLayer)

                let filepath = "/Users/jiechen/Downloads/scent-of-woman/out-of-order.mp4"
//                let filepath = "/Users/jiechen/Downloads/mp4-subs/OUTPUT.mp4"
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
