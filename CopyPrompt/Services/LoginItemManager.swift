import Foundation
import ServiceManagement

enum LoginItemError: Error {
    case registrationFailed
    case unregistrationFailed
    case statusCheckFailed
}

class LoginItemManager: ObservableObject {
    static let shared = LoginItemManager()

    @Published var isEnabled: Bool {
        didSet {
            if isEnabled != oldValue {
                updateLoginItem(isEnabled)
            }
        }
    }

    private init() {
        self.isEnabled = Self.checkStatus()
    }

    private static func checkStatus() -> Bool {
        return SMAppService.mainApp.status == .enabled
    }

    private func updateLoginItem(_ shouldEnable: Bool) {
        do {
            if shouldEnable {
                if SMAppService.mainApp.status == .enabled {
                    return
                }
                try SMAppService.mainApp.register()
            } else {
                if SMAppService.mainApp.status != .enabled {
                    return
                }
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update login item: \(error)")
            DispatchQueue.main.async {
                self.isEnabled = Self.checkStatus()
            }
        }
    }

    func refresh() {
        DispatchQueue.main.async {
            self.isEnabled = Self.checkStatus()
        }
    }
}
