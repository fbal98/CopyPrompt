import Foundation

struct PromptList: Codable {
    var schemaVersion: Int
    var prompts: [Prompt]

    init(prompts: [Prompt] = [], schemaVersion: Int = 1) {
        self.prompts = prompts
        self.schemaVersion = schemaVersion
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case prompts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Default to version 1 if not present (for backward compatibility)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 1
        prompts = try container.decode([Prompt].self, forKey: .prompts)
    }
}
