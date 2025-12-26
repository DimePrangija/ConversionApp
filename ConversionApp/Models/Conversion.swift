import Foundation
import SwiftData

enum ConversionUnit: String, Codable, CaseIterable, Identifiable {
    case pounds
    case kilograms

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pounds: return "Pounds (lb)"
        case .kilograms: return "Kilograms (kg)"
        }
    }

    var shortLabel: String {
        switch self {
        case .pounds: return "lb"
        case .kilograms: return "kg"
        }
    }
}

enum ConversionDirection: String, Codable, CaseIterable, Identifiable {
    case poundsToKilograms
    case kilogramsToPounds

    var id: String { rawValue }

    var from: ConversionUnit {
        switch self {
        case .poundsToKilograms: return .pounds
        case .kilogramsToPounds: return .kilograms
        }
    }

    var to: ConversionUnit {
        switch self {
        case .poundsToKilograms: return .kilograms
        case .kilogramsToPounds: return .pounds
        }
    }

    var label: String {
        switch self {
        case .poundsToKilograms: return "lb → kg"
        case .kilogramsToPounds: return "kg → lb"
        }
    }

    var accessibleLabel: String {
        switch self {
        case .poundsToKilograms: return "Pounds to kilograms"
        case .kilogramsToPounds: return "Kilograms to pounds"
        }
    }
}

@Model
final class ConversionRecord: Identifiable {
    @Attribute(.unique) var id: UUID
    var inputValue: Double
    var fromUnitRaw: String
    var toUnitRaw: String
    var resultValue: Double
    var timestamp: Date
    var isSynced: Bool

    init(
        id: UUID = UUID(),
        inputValue: Double,
        fromUnit: ConversionUnit,
        toUnit: ConversionUnit,
        resultValue: Double,
        timestamp: Date = .now,
        isSynced: Bool = false
    ) {
        self.id = id
        self.inputValue = inputValue
        self.fromUnitRaw = fromUnit.rawValue
        self.toUnitRaw = toUnit.rawValue
        self.resultValue = resultValue
        self.timestamp = timestamp
        self.isSynced = isSynced
    }

    var fromUnit: ConversionUnit {
        ConversionUnit(rawValue: fromUnitRaw) ?? .pounds
    }

    var toUnit: ConversionUnit {
        ConversionUnit(rawValue: toUnitRaw) ?? .kilograms
    }

    var direction: ConversionDirection {
        if fromUnit == .pounds {
            return .poundsToKilograms
        } else {
            return .kilogramsToPounds
        }
    }
}
