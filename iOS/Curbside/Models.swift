import Foundation

struct RefundVisit: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var center: String
    var refundAmount: Double
    var visitDate: Date
    var itemCount: Int
    var notes: String

    init(id: UUID = UUID(), center: String = "", refundAmount: Double = 0.0, visitDate: Date = Date(), itemCount: Int = 0, notes: String = "") {
        self.id = id
        self.center = center
        self.refundAmount = refundAmount
        self.visitDate = visitDate
        self.itemCount = itemCount
        self.notes = notes
    }
}
