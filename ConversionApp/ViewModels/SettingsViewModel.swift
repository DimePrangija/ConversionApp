import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var defaultDirection: ConversionDirection
    @Published var decimalPlaces: Int
    @Published var hapticsEnabled: Bool

    private let userSettings: UserSettings

    init(userSettings: UserSettings) {
        self.userSettings = userSettings
        self.defaultDirection = userSettings.defaultDirection
        self.decimalPlaces = userSettings.decimalPlaces
        self.hapticsEnabled = userSettings.hapticsEnabled
    }

    func save() {
        userSettings.defaultDirection = defaultDirection
        userSettings.decimalPlaces = decimalPlaces
        userSettings.hapticsEnabled = hapticsEnabled
    }
}
