import Foundation

struct Prompt: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var body: String
    var position: Int
    var updatedAt: Date

    init(id: UUID = UUID(), title: String, body: String, position: Int, updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.body = body
        self.position = position
        self.updatedAt = updatedAt
    }
}
