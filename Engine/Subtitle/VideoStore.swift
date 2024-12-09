
import Foundation
import SwiftData
import Common

public class VideoStore {
    public static var shared = VideoStore()

    let container: ModelContainer

    private init() {
        let dbPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("vpv.db")
        let configuration = ModelConfiguration(url: dbPath)
        self.container = try! ModelContainer(for: VideoModel.self, configurations: configuration)
    }

    @MainActor
    public func insert(video: VideoModel) -> UUID {
        video.id = UUID()
        container.mainContext.insert(video)
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
    public func query(filepath: String) -> VideoModel? {
        let descriptor = FetchDescriptor<VideoModel>(
            predicate: #Predicate<VideoModel> { $0.filepath == filepath }
        )
        return try? container.mainContext.fetch(descriptor).first
    }

    @MainActor
    public func query(movieID: UUID) -> VideoModel? {
        let descriptor = FetchDescriptor<VideoModel>(
            predicate: #Predicate<VideoModel> { $0.movieID == movieID }
        )
        return try? container.mainContext.fetch(descriptor).first
    }

    @MainActor
    public func query(hash: String) -> VideoModel? {
        let descriptor = FetchDescriptor<VideoModel>(
            predicate: #Predicate<VideoModel> { $0.hash == hash }
        )
        return try? container.mainContext.fetch(descriptor).first
    }

    @MainActor
    public func query(id: UUID) -> VideoModel? {
        let descriptor = FetchDescriptor<VideoModel>(
            predicate: #Predicate<VideoModel> { $0.id == id }
        )
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
