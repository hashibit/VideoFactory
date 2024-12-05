//
//  VideoModel.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/12/5.
//

import Foundation
import SwiftData


@Model
class VideoModel {
    var id: Int
    var parentId: Int
    var origin: String
    var movieID: Int
    var filepath: String
    var trackID: String
    var hash: String
    var filesize: Int64
    var encMethod: String
    var language: String
    var duration: Int
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date

    init(id: Int, parentId: Int, origin: String, movieID: Int, filepath: String, trackID: String, hash: String, filesize: Int64, encMethod: String, language: String, duration: Int, createdAt: Date, updatedAt: Date, deletedAt: Date) {
        self.id = id
        self.parentId = parentId
        self.origin = origin
        self.movieID = movieID
        self.filepath = filepath
        self.trackID = trackID
        self.hash = hash
        self.filesize = filesize
        self.encMethod = encMethod
        self.language = language
        self.duration = duration
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    static func createEmbededSubTrack(movieId: Int, trackId: String) -> VideoModel {
        return VideoModel(
            id: 0,
            parentId: 0,
            origin: "embeded",
            movieID: movieId,
            filepath: "",
            trackID: trackId,
            hash: "",
            filesize: 0,
            encMethod: "",
            language: "",
            duration: 0,
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: Date()
        )
    }

    static func createFromFilepath(movieId: Int, filepath: String) -> VideoModel {
        return createFromFilepath(movieId: movieId, filepath: filepath, origin: "unset")
    }

    static func createFromFilepath(movieId: Int, filepath: String, origin: String) -> VideoModel {
        let hash = generateHash(filepath) ?? ""
        return VideoModel(
            id: 0,
            parentId: 0,
            origin: origin,
            movieID: movieId,
            filepath: filepath,
            trackID: "",
            hash: hash,
            filesize: 0,
            encMethod: "",
            language: "",
            duration: 0,
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: Date()
        )
    }

    func copy(from source: VideoModel) {
        self.id = source.id
        self.parentId = source.parentId
        self.origin = source.origin
        self.trackID = source.trackID
        self.filesize = source.filesize
        self.hash = source.hash
        self.encMethod = source.encMethod
        self.language = source.language
        self.duration = source.duration
        self.createdAt = source.createdAt
        self.updatedAt = source.updatedAt
        self.deletedAt = source.deletedAt
    }

    func smartKey() -> String {
        if origin == SubtitleOrigin.transcribe.rawValue {
            return "语音识别字幕:\(id)"
        } else if origin == SubtitleOrigin.translate.rawValue {
            return "翻译字幕(\(language)):\(id)"
        }
        return ""
    }

}
