
import Common
import Foundation
import SwiftData

public class VideoStore {
    public static var shared = VideoStore()

    let container: ModelContainer

    private init() {
        let dbPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("vpv.db")
        let configuration = ModelConfiguration(url: dbPath)
        container = try! ModelContainer(for: VideoModel.self, configurations: configuration)
    }

    @MainActor
    public func insert(video: VideoModel) -> UUID {
        container.mainContext.insert(video)
        try? container.mainContext.save()
        return video.id
    }

    @MainActor
    public func save() {
        try? container.mainContext.save()
    }

    @MainActor
    public func query(id: UUID? = nil, filepath: String? = nil, fileHash: String? = nil) -> VideoModel? {
        let descriptor: FetchDescriptor<VideoModel>
        if let id {
            print("query video model by id: \(id)")
            descriptor = FetchDescriptor<VideoModel>(predicate: #Predicate<VideoModel> { $0.id == id })
        } else if let fileHash {
            print("query video model by file hash: \(fileHash)")
            descriptor = FetchDescriptor<VideoModel>(predicate: #Predicate<VideoModel> { $0.fileHash == fileHash })
        } else if let filepath {
            print("query video model by filepath: \(filepath)")
            descriptor = FetchDescriptor<VideoModel>(predicate: #Predicate<VideoModel> { $0.filepath == filepath })
        } else {
            print("query video model by no condition, so return nil")
            return nil
        }
        return try? container.mainContext.fetch(descriptor).first
    }

    @MainActor
    public func remove(id: UUID) -> VideoModel? {
        let descriptor = FetchDescriptor<VideoModel>(
            predicate: #Predicate<VideoModel> { $0.id == id }
        )
        if let video = try? container.mainContext.fetch(descriptor).first {
            container.mainContext.delete(video)
            try? container.mainContext.save()
            return video
        }
        return nil
    }

    @MainActor
    public func findOrCreateVideoModel(_ filepath: String) -> VideoModel? {
        var filepath = filepath

        if let url = URL(string: filepath) {
            filepath = url.path
        }
        guard FileManager.default.fileExists(atPath: filepath) else {
            print("file not exists: \(filepath)")
            return nil
        }

        // query database
        if let model = query(filepath: filepath) {
            print("found video model at filepath: \(filepath)")
            return model
        }

        // calculate file hash
        guard let fileHash = generateHash(filepath) else {
            print("failed to generate hash for filepath: \(filepath)")
            return nil
        }

        // query database by file hash
        if let model = query(fileHash: fileHash) {
            print("found video model for file hash: \(fileHash), but filepath is not matched: \(filepath)")

            var oldFilepaths = model.legacyFilepaths.split(separator: ",").map { String($0) }
            oldFilepaths.append(filepath)

            model.legacyFilepaths = oldFilepaths.joined(separator: ",")
            model.filepath = filepath
            save()
            return model
        }

        // create new video model
        let videoModel = VideoModel(filepath: filepath, fileHash: fileHash)
        print("created new video model for filepath: \(filepath)")
        videoModel.id = insert(video: videoModel)

        return videoModel
    }

}
