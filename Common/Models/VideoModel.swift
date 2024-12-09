//
//  VideoModel.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/12/5.
//
import Foundation
import SwiftData

@Model
public class VideoModel {

    public var id: UUID
    public var parentID: UUID
    public var origin: String
    public var movieID: UUID
    public var filepath: String
    public var trackID: UUID
    public var hash: String
    public var filesize: Int64
    public var encMethod: String
    public var language: String
    public var duration: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date

    public init(id: UUID, parentID: UUID, origin: String, movieID: UUID, filepath: String, trackID: UUID,
         hash: String, filesize: Int64, encMethod: String, language: String, duration: Int,
         createdAt: Date = Date(), updatedAt: Date = Date(), deletedAt: Date = Date()) {
        self.id = id
        self.parentID = parentID
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

    public convenience init() {
        self.init(id: UUID(),
                  parentID: UUID(),
                  origin: "",
                  movieID: UUID(),
                  filepath: "",
                  trackID: UUID(),
                  hash: "",
                  filesize: 0,
                  encMethod: "",
                  language: "",
                  duration: 0)
    }

    public static func createEmbededSubTrack(movieId: UUID, trackId: UUID) -> VideoModel {
        return VideoModel(
            id: UUID(),
            parentID: UUID(),
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

    public static func createFromFilepath(movieId: UUID, filepath: String) -> VideoModel {
        return createFromFilepath(movieId: movieId, filepath: filepath, origin: "unset")
    }

    public static func createFromFilepath(movieId: UUID, filepath: String, origin: String) -> VideoModel {
        let hash = generateHash(filepath) ?? ""
        return VideoModel(
            id: UUID(),
            parentID: UUID(),
            origin: origin,
            movieID: movieId,
            filepath: filepath,
            trackID: UUID(),
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

    public func copy(from source: VideoModel) {
        self.id = source.id
        self.parentID = source.parentID
        self.origin = source.origin
        self.movieID = source.movieID
        self.filepath = source.filepath
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

    public func smartKey() -> String {
        if origin == SubtitleOrigin.transcribe.rawValue {
            return "语音识别字幕:\(id)"
        } else if origin == SubtitleOrigin.translate.rawValue {
            return "翻译字幕(\(language)):\(id)"
        }
        return ""
    }

}
