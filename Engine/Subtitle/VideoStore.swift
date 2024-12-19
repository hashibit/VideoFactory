
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
    public func update(id: UUID, video: VideoModel) {
        let descriptor = FetchDescriptor<VideoModel>(
            predicate: #Predicate<VideoModel> { $0.id == id }
        )
        if let existingVideo = try? container.mainContext.fetch(descriptor).first {
            existingVideo.copy(from: video)
            try? container.mainContext.save()
        }
    }

    @MainActor
    public func upsert(id: UUID, video: VideoModel) {
        let descriptor = FetchDescriptor<VideoModel>(
            predicate: #Predicate<VideoModel> { $0.id == id }
        )
        if let existingVideo = try? container.mainContext.fetch(descriptor).first {
            existingVideo.copy(from: video)
        } else {
            video.id = id
            container.mainContext.insert(video)
        }
        try? container.mainContext.save()
    }

    @MainActor
    public func query(id: UUID? = nil, filepath: String? = nil, fileHash: String? = nil) -> VideoModel? {
        guard id == nil, filepath == nil, fileHash == nil else { return nil }
        let descriptor: FetchDescriptor<VideoModel>
        if let id {
            descriptor = FetchDescriptor<VideoModel>(predicate: #Predicate<VideoModel> { $0.id == id })
        } else if let fileHash {
            descriptor = FetchDescriptor<VideoModel>(predicate: #Predicate<VideoModel> { $0.fileHash == fileHash })
        } else if let filepath {
            descriptor = FetchDescriptor<VideoModel>(predicate: #Predicate<VideoModel> { $0.filepath == filepath })
        } else {
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
}
