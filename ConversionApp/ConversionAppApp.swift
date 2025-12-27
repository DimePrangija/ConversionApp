import SwiftUI
import SwiftData

@main
struct ConversionAppApp: App {
    @State private var persistenceController = PersistenceController.shared
    private let apiClient = APIClient()
    private let hapticsService = HapticsService()
    private let userSettings = UserSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.persistenceController, persistenceController)
                .environment(\.apiClient, apiClient)
                .environment(\.hapticsService, hapticsService)
                .environment(\.userSettings, userSettings)
                .modelContainer(persistenceController.container)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Environment Keys
private struct PersistenceControllerKey: EnvironmentKey {
    static let defaultValue: PersistenceController = .shared
}

private struct APIClientKey: EnvironmentKey {
    static let defaultValue: APIClient = APIClient()
}

private struct HapticsServiceKey: EnvironmentKey {
    static let defaultValue: HapticsService = HapticsService()
}

private struct UserSettingsKey: EnvironmentKey {
    static let defaultValue: UserSettings = UserSettings()
}

extension EnvironmentValues {
    var persistenceController: PersistenceController {
        get { self[PersistenceControllerKey.self] }
        set { self[PersistenceControllerKey.self] = newValue }
    }

    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }

    var hapticsService: HapticsService {
        get { self[HapticsServiceKey.self] }
        set { self[HapticsServiceKey.self] = newValue }
    }

    var userSettings: UserSettings {
        get { self[UserSettingsKey.self] }
        set { self[UserSettingsKey.self] = newValue }
    }
}
