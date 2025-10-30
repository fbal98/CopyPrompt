import Foundation

enum PromptStoreError: Error {
    case directoryCreationFailed
    case loadFailed(Error)
    case saveFailed(Error)
    case corruptedData
    case migrationFailed(fromVersion: Int, toVersion: Int)
    case unsupportedSchemaVersion(Int)

    var localizedDescription: String {
        switch self {
        case .directoryCreationFailed:
            "Failed to create application directory"
        case let .loadFailed(error):
            "Failed to load prompts: \(error.localizedDescription)"
        case let .saveFailed(error):
            "Failed to save prompts: \(error.localizedDescription)"
        case .corruptedData:
            "Data file is corrupted"
        case let .migrationFailed(from, to):
            "Failed to migrate data from version \(from) to \(to)"
        case let .unsupportedSchemaVersion(version):
            "Unsupported schema version: \(version)"
        }
    }
}

class PromptStore: ObservableObject {
    @Published private(set) var prompts: [Prompt] = []
    @Published var lastError: PromptStoreError?

    private let fileManager = FileManager.default
    private let fileName = "data.json"
    private let backupFileName = "data.json.bak"
    private let currentSchemaVersion = 1

    private var dataFileURL: URL {
        get throws {
            let appSupport = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )

            let appDirectory = appSupport.appendingPathComponent("CopyPrompt", isDirectory: true)

            if !fileManager.fileExists(atPath: appDirectory.path) {
                try fileManager.createDirectory(
                    at: appDirectory,
                    withIntermediateDirectories: true
                )
            }

            return appDirectory.appendingPathComponent(fileName)
        }
    }

    private var backupFileURL: URL {
        get throws {
            let dataURL = try dataFileURL
            return dataURL.deletingLastPathComponent().appendingPathComponent(backupFileName)
        }
    }

    func load() throws {
        do {
            let url = try dataFileURL

            guard fileManager.fileExists(atPath: url.path) else {
                prompts = []
                lastError = nil
                return
            }

            let data = try Data(contentsOf: url)
            var promptList = try JSONDecoder().decode(PromptList.self, from: data)

            // Migrate if needed
            if promptList.schemaVersion < currentSchemaVersion {
                promptList = try migrate(promptList, to: currentSchemaVersion)
                // Save migrated data
                try savePromptList(promptList)
            } else if promptList.schemaVersion > currentSchemaVersion {
                throw PromptStoreError.unsupportedSchemaVersion(promptList.schemaVersion)
            }

            prompts = promptList.prompts.sorted { $0.position < $1.position }
            lastError = nil
        } catch {
            // Try backup recovery
            do {
                let backupURL = try backupFileURL

                guard fileManager.fileExists(atPath: backupURL.path) else {
                    lastError = PromptStoreError.loadFailed(error)
                    throw PromptStoreError.loadFailed(error)
                }

                let data = try Data(contentsOf: backupURL)
                var promptList = try JSONDecoder().decode(PromptList.self, from: data)

                // Migrate backup if needed
                if promptList.schemaVersion < currentSchemaVersion {
                    promptList = try migrate(promptList, to: currentSchemaVersion)
                }

                prompts = promptList.prompts.sorted { $0.position < $1.position }

                // Restore from backup
                try save()
                lastError = nil
            } catch {
                lastError = PromptStoreError.loadFailed(error)
                throw PromptStoreError.loadFailed(error)
            }
        }
    }

    func save() throws {
        let promptList = PromptList(prompts: prompts, schemaVersion: currentSchemaVersion)
        try savePromptList(promptList)
    }

    private func savePromptList(_ promptList: PromptList) throws {
        do {
            let url = try dataFileURL
            let backupURL = try backupFileURL

            // Create backup before saving
            if fileManager.fileExists(atPath: url.path) {
                try? fileManager.removeItem(at: backupURL)
                try? fileManager.copyItem(at: url, to: backupURL)
            }

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(promptList)

            try data.write(to: url, options: .atomic)
            lastError = nil
        } catch {
            lastError = PromptStoreError.saveFailed(error)
            throw PromptStoreError.saveFailed(error)
        }
    }

    private func migrate(_ promptList: PromptList, to version: Int) throws -> PromptList {
        var migrated = promptList

        // Migration stub for future schema changes
        // Example: if migrated.schemaVersion == 1 && version >= 2 {
        //     migrated = migrateV1ToV2(migrated)
        // }

        migrated.schemaVersion = version
        return migrated
    }

    func add(_ prompt: Prompt) throws {
        prompts.append(prompt)
        try save()
    }

    func update(_ prompt: Prompt) throws {
        if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
            prompts[index] = prompt
            try save()
        }
    }

    func delete(_ prompt: Prompt) throws {
        prompts.removeAll { $0.id == prompt.id }
        try save()
    }

    func reorder(from source: IndexSet, to destination: Int) throws {
        prompts.move(fromOffsets: source, toOffset: destination)
        for index in prompts.indices {
            prompts[index].position = index
        }
        try save()
    }

    func pin(_ prompt: Prompt, preferences: AppPreferences) throws {
        guard let currentIndex = prompts.firstIndex(where: { $0.id == prompt.id }) else {
            return
        }

        let currentPinnedCount = preferences.pinnedCount

        // If already pinned, do nothing
        if currentIndex < currentPinnedCount {
            return
        }

        // Move to the end of pinned section
        let sourceIndexSet = IndexSet(integer: currentIndex)
        prompts.move(fromOffsets: sourceIndexSet, toOffset: currentPinnedCount)

        // Update positions
        for index in prompts.indices {
            prompts[index].position = index
        }

        // Increment pinned count
        preferences.pinnedCount += 1

        try save()
    }

    func unpin(_ prompt: Prompt, preferences: AppPreferences) throws {
        guard let currentIndex = prompts.firstIndex(where: { $0.id == prompt.id }) else {
            return
        }

        let currentPinnedCount = preferences.pinnedCount

        // If not pinned, do nothing
        if currentIndex >= currentPinnedCount {
            return
        }

        // Decrement pinned count first
        preferences.pinnedCount = max(0, currentPinnedCount - 1)

        // Move to first position after pinned section
        let sourceIndexSet = IndexSet(integer: currentIndex)
        prompts.move(fromOffsets: sourceIndexSet, toOffset: preferences.pinnedCount)

        // Update positions
        for index in prompts.indices {
            prompts[index].position = index
        }

        try save()
    }
}
