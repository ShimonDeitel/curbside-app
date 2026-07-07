import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [RefundVisit] = []
    @Published var isPro: Bool = false

    /// Free tier allows this many entries. Seed data below is always fewer than this
    /// so a fresh install never opens straight into the paywall.
    static let freeLimit = 20

    private let fileName = "curbside_items.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([RefundVisit].self, from: data) else {
            items = Self.seedData()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    var canAddMore: Bool {
        isPro || items.count < Self.freeLimit
    }

    @discardableResult
    func add(_ item: RefundVisit) -> Bool {
        guard canAddMore else { return false }
        items.append(item)
        save()
        return true
    }

    func update(_ item: RefundVisit) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: RefundVisit) {
        items.removeAll { $0.id == item.id }
        save()
    }

    static func seedData() -> [RefundVisit] {
        [
        RefundVisit(center: "City Recycling Center", refundAmount: 3.5, visitDate: Date().addingTimeInterval(-259200), itemCount: 1, notes: ""),
        RefundVisit(center: "Greenway Depot", refundAmount: 5.75, visitDate: Date().addingTimeInterval(-518400), itemCount: 2, notes: "Weekly run"),
        RefundVisit(center: "City Recycling Center", refundAmount: 8.0, visitDate: Date().addingTimeInterval(-777600), itemCount: 3, notes: ""),
        RefundVisit(center: "Greenway Depot", refundAmount: 10.25, visitDate: Date().addingTimeInterval(-1036800), itemCount: 4, notes: "Weekly run")
        ]
    }
}
