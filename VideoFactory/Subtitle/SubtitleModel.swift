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
}
