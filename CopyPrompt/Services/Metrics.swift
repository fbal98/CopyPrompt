import Foundation

struct MetricsEvent: Codable {
    let timestamp: Date
    let eventType: String
    let duration: TimeInterval?
    let metadata: [String: String]?
}

struct MetricsLog: Codable {
    var events: [MetricsEvent]
    var stats: MetricsStats?
}

struct MetricsStats: Codable {
    let ttcP50: TimeInterval?
    let ttcP95: TimeInterval?
    let avgSearchTime: TimeInterval?
    let totalEvents: Int
}

class Metrics: ObservableObject {
    static let shared = Metrics()

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "metricsEnabled")
        }
    }

    private let fileManager = FileManager.default
    private let fileName = "logs.json"
    private var events: [MetricsEvent] = []

    private var logsFileURL: URL? {
        do {
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
        } catch {
            print("Failed to get logs file URL: \(error)")
            return nil
        }
    }

    private init() {
        isEnabled = UserDefaults.standard.bool(forKey: "metricsEnabled")
        loadEvents()
    }

    func log(eventType: String, duration: TimeInterval? = nil, metadata: [String: String]? = nil) {
        guard isEnabled else { return }

        let event = MetricsEvent(
            timestamp: Date(),
            eventType: eventType,
            duration: duration,
            metadata: metadata
        )

        events.append(event)

        // Only keep last 1000 events
        if events.count > 1000 {
            events.removeFirst(events.count - 1000)
        }

        saveEvents()
    }

    func reset() {
        events.removeAll()
        saveEvents()
    }

    func getStats() -> MetricsStats {
        let ttcEvents = events
            .filter { $0.eventType == "time-to-copy" }
            .compactMap(\.duration)
            .sorted()

        let searchEvents = events
            .filter { $0.eventType == "search-keystroke" }
            .compactMap(\.duration)

        let ttcP50: TimeInterval? = ttcEvents.isEmpty ? nil : percentile(ttcEvents, percentile: 0.50)
        let ttcP95: TimeInterval? = ttcEvents.isEmpty ? nil : percentile(ttcEvents, percentile: 0.95)
        let avgSearchTime: TimeInterval? = searchEvents.isEmpty ? nil :
            searchEvents.reduce(0, +) / Double(searchEvents.count)

        return MetricsStats(
            ttcP50: ttcP50,
            ttcP95: ttcP95,
            avgSearchTime: avgSearchTime,
            totalEvents: events.count
        )
    }

    private func percentile(_ values: [TimeInterval], percentile: Double) -> TimeInterval {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let index = Int(Double(sorted.count) * percentile)
        return sorted[min(index, sorted.count - 1)]
    }

    private func loadEvents() {
        guard let url = logsFileURL,
              fileManager.fileExists(atPath: url.path)
        else {
            events = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let log = try JSONDecoder().decode(MetricsLog.self, from: data)
            events = log.events
        } catch {
            print("Failed to load metrics: \(error)")
            events = []
        }
    }

    private func saveEvents() {
        guard let url = logsFileURL else { return }

        let log = MetricsLog(
            events: events,
            stats: getStats()
        )

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(log)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Failed to save metrics: \(error)")
        }
    }
}
