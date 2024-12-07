//
//  SubtitleModel.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/12/5.
//

import Foundation
import SwiftData

enum SubtitleOrigin: String {
    case transcribe
    case translate
}

@Model
class SubtitleModel {

    var id: UUID
    var parentID: UUID
    var origin: String
    var movieID: UUID
    var filepath: String
    var trackID: UUID
    var hash: String
    var filesize: Int
    var encMethod: String
    var language: String
    var duration: Int
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date

    init(id: UUID, parentID: UUID, origin: String, movieID: UUID, filepath: String, trackID: UUID,
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

    convenience init() {
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

    func copy(from: SubtitleModel) {
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
