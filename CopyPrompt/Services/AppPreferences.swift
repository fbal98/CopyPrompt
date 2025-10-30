import Foundation

class AppPreferences: ObservableObject {
    static let shared = AppPreferences()

    @Published var pinnedCount: Int {
        didSet {
            UserDefaults.standard.set(pinnedCount, forKey: "pinnedCount")
        }
    }

    private init() {
        let savedCount = UserDefaults.standard.integer(forKey: "pinnedCount")
        self.pinnedCount = savedCount > 0 ? savedCount : 3
    }
}
