import Foundation
import SwiftData

@MainActor
final class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    private init(inMemory: Bool = false) {
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            container = try ModelContainer(for: ConversionRecord.self, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }

    static func makePreview() -> PersistenceController {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.mainContext
        for index in 0..<5 {
            let value = Double(index) * 10.0 + 1.5
            let record = ConversionRecord(inputValue: value, fromUnit: .pounds, toUnit: .kilograms, resultValue: value * ConversionService.poundsToKilogramsFactor)
            context.insert(record)
        }
        return controller
    }
}
