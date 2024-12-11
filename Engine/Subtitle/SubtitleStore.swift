import Foundation
import SwiftData
import Common

public class SubtitleStore {
    public static var shared = SubtitleStore()

    let container: ModelContainer

    private init() {
        let dbPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("vps.db")
        let configuration = ModelConfiguration(url: dbPath)
        self.container = try! ModelContainer(for: SubtitleModel.self, configurations: configuration)
    }

    @MainActor
    public func insert(subtitle: SubtitleModel) -> UUID {
        subtitle.id = UUID()
        container.mainContext.insert(subtitle)
        return subtitle.id
    }
    @MainActor
    public func update(id: UUID, subtitle: SubtitleModel) {
        let descriptor = FetchDescriptor<SubtitleModel>(
            predicate: #Predicate<SubtitleModel> { $0.id == id }
        )
        if let existingSubtitle = try? container.mainContext.fetch(descriptor).first {
            existingSubtitle.copy(from: subtitle)
            try? container.mainContext.save()
        }
    }

    @MainActor
    public func upsert(id: UUID, subtitle: SubtitleModel) {
        let descriptor = FetchDescriptor<SubtitleModel>(
            predicate: #Predicate<SubtitleModel> { $0.id == id }
        )
        if let existingSubtitle = try? container.mainContext.fetch(descriptor).first {
            existingSubtitle.copy(from: subtitle)
        } else {
            subtitle.id = id
            container.mainContext.insert(subtitle)
        }
        try? container.mainContext.save()
    }

    @MainActor
    public func query(filepath: String) -> SubtitleModel? {
        let descriptor = FetchDescriptor<SubtitleModel>(
            predicate: #Predicate<SubtitleModel> { $0.filepath == filepath }
        )
        return try? container.mainContext.fetch(descriptor).first
    }

    @MainActor
    public func query(videoID: UUID?) -> [SubtitleModel] {
        guard let videoID else { return [] }
        let descriptor = FetchDescriptor<SubtitleModel>(
            predicate: #Predicate<SubtitleModel> { $0.movieID == videoID }
        )
        return (try? container.mainContext.fetch(descriptor)) ?? []
    }

    @MainActor
    public func query(hash: String) -> SubtitleModel? {
        let descriptor = FetchDescriptor<SubtitleModel>(
            predicate: #Predicate<SubtitleModel> { $0.hash == hash }
        )
        return try? container.mainContext.fetch(descriptor).first
    }

    @MainActor
    public func query(id: UUID) -> SubtitleModel? {
        let descriptor = FetchDescriptor<SubtitleModel>(
            predicate: #Predicate<SubtitleModel> { $0.id == id }
        )
        return try? container.mainContext.fetch(descriptor).first
    }

    @MainActor
    public func remove(id: UUID) -> SubtitleModel? {
        let descriptor = FetchDescriptor<SubtitleModel>(
            predicate: #Predicate<SubtitleModel> { $0.id == id }
        )
        if let subtitle = try? container.mainContext.fetch(descriptor).first {
            container.mainContext.delete(subtitle)
            try? container.mainContext.save()
            return subtitle
        }
        return nil
    }

}
