import Foundation
import SwiftUI

final class UserSettings: ObservableObject {
    enum Keys {
        static let defaultDirection = "defaultDirection"
        static let decimalPlaces = "decimalPlaces"
        static let hapticsEnabled = "hapticsEnabled"
    }

    @AppStorage(Keys.defaultDirection) var defaultDirection: ConversionDirection = .poundsToKilograms
    @AppStorage(Keys.decimalPlaces) var decimalPlaces: Int = 2
    @AppStorage(Keys.hapticsEnabled) var hapticsEnabled: Bool = true
}
