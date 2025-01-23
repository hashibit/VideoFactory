//
//  SubtitlesViewModel.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/12/11.
//

import Foundation

import Common
import Engine

@MainActor
@Observable
public class SubtitlesViewModel {
    public var embededSubtitles: [SubtitleModel] = []
    public var externalSubtitles: [SubtitleModel] = []
    public var transcribeSubtitles: [SubtitleModel] = []
    public var translateSubtitles: [SubtitleModel] = []

    public var selectedSubtitleID: UUID?

    func fetchSubtitlesFromDB(videoID: UUID) {
        print("fetch subtitles for videoID: \(String(describing: videoID))")
        let allSubtitles = SubtitleStore.shared.query(videoID: videoID)

        // 分类处理
        embededSubtitles = allSubtitles.filter { $0.origin == "embeded" }
        externalSubtitles = allSubtitles.filter { $0.origin == "external" }
        transcribeSubtitles = allSubtitles.filter { $0.origin == "transcribe" }
        translateSubtitles = allSubtitles.filter { $0.origin == "translate" }
    }

    func loadSubtitlesFromTracks(_ videoID: UUID, _ trackList: [[String: Any]]) {
        print("call loadSubtitlesFromTracks, trackList: \(trackList)")
        embededSubtitles = trackList.map {
            SubtitleModel(movieID: videoID,
                         trackID: $0["id"] as? Int ?? -1,
                         origin: SubtitleOrigin.embeded.rawValue,
                         language: $0["language"] as? String ?? "")
        }
        print("loaded subtitles from tracks: \(embededSubtitles)")
    }
}
