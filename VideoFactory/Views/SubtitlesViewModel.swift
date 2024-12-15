//
//  SubtitlesViewModel.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/12/11.
//

import Foundation

import Common
import Engine

class SubtitlesViewModel: ObservableObject {
    @Published var embededSubtitles: [SubtitleModel] = []
    @Published var externalSubtitles: [SubtitleModel] = []
    @Published var transcribeSubtitles: [SubtitleModel] = []
    @Published var translateSubtitles: [SubtitleModel] = []

    @Published var selectedSubtitleID: UUID?

    @MainActor
    func fetchSubtitles(videoID: UUID?) {
        print("fetch subtitles for videoID: \(String(describing: videoID))")
        let allSubtitles = SubtitleStore.shared.query(videoID: videoID)

        // 分类处理
        embededSubtitles = allSubtitles.filter { $0.origin == "embeded" }
        externalSubtitles = allSubtitles.filter { $0.origin == "external" }
        transcribeSubtitles = allSubtitles.filter { $0.origin == "transcribe" }
        translateSubtitles = allSubtitles.filter { $0.origin == "translate" }
    }
}
