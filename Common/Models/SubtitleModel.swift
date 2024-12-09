//
//  SubtitleModel.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/12/5.
//

import Foundation
import SwiftData

public enum SubtitleOrigin: String {
    case transcribe
    case translate
}

@Model
public class SubtitleModel: Identifiable {

    public var id: UUID
    public var parentID: UUID
    public var origin: String
    public var movieID: UUID
    public var filepath: String
    public var trackID: UUID
    public var hash: String
    public var filesize: Int
    public var encMethod: String
    public var language: String
    public var duration: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date

    public init(id: UUID, parentID: UUID, origin: String, movieID: UUID, filepath: String, trackID: UUID,
         hash: String, filesize: Int, encMethod: String, language: String, duration: Int,
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
        self.init(id : UUID(),
                  parentID : UUID(),
                  origin : "",
                  movieID : UUID(),
                  filepath : "",
                  trackID : UUID(),
                  hash : "",
                  filesize : 0,
                  encMethod : "",
                  language : "",
                  duration : 0
        )
    }

    public func copy(from: SubtitleModel) {
        self.parentID = from.parentID
        self.origin = from.origin
        self.movieID = from.movieID
        self.filepath = from.filepath
        self.trackID = from.trackID
        self.hash = from.hash
        self.filesize = from.filesize
        self.encMethod = from.encMethod
        self.language = from.language
        self.duration = from.duration
    }
}
