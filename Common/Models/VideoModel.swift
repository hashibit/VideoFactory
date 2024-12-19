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
    public var filepath: String
    public var legacyFilepaths: String
    public var filename: String
    public var fileExtension: String
    public var fileHash: String
    public var filesize: Int64
    public var duration: Int
    public var lastPlayTime: Date
    public var lastPosition: Int
    public var lastEnabledSid: Int
    public var lastEnabledAid: Int
    public var totalPlayCount: Int

    public init(id: UUID, filepath: String, legacyFilepaths: String,
                filename: String, fileExtension: String, fileHash: String, filesize: Int64, duration: Int,
                lastPlayTime: Date, lastPosition: Int, lastEnabledSid: Int, lastEnabledAid: Int, totalPlayCount: Int) {
        self.id = id
        self.filepath = filepath
        self.legacyFilepaths = legacyFilepaths
        self.filename = filename
        self.fileExtension = fileExtension
        self.fileHash = fileHash
        self.filesize = filesize
        self.duration = duration
        self.lastPlayTime = lastPlayTime
        self.lastPosition = lastPosition
        self.lastEnabledSid = lastEnabledSid
        self.lastEnabledAid = lastEnabledAid
        self.totalPlayCount = totalPlayCount
    }

    public convenience init(filepath: String, fileHash: String?) {
        let hash = fileHash ?? generateHash(filepath) ?? ""
        self.init(id: UUID(),
                  filepath: filepath,
                  legacyFilepaths: "",
                  filename: "",
                  fileExtension: "",
                  fileHash: hash,
                  filesize: 0,
                  duration: 0,
                  lastPlayTime: Date(),
                  lastPosition: 0,
                  lastEnabledSid: 0,
                  lastEnabledAid: 0,
                  totalPlayCount: 0)
    }

    public func update(from: VideoModel) {
        self.filepath = from.filepath
        self.legacyFilepaths = from.legacyFilepaths
        self.filename = from.filename
        self.fileExtension = from.fileExtension
        self.fileHash = from.fileHash
        self.filesize = from.filesize
        self.duration = from.duration
        self.lastPlayTime = from.lastPlayTime
        self.lastPosition = from.lastPosition
        self.lastEnabledSid = from.lastEnabledSid
        self.lastEnabledAid = from.lastEnabledAid
        self.totalPlayCount = from.totalPlayCount
    }

}
