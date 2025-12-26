import Foundation
import SwiftData

@MainActor
final class SyncService {
    func syncPendingRecords(context: ModelContext, apiClient: APIClient) async {
        let descriptor = FetchDescriptor<ConversionRecord>(predicate: #Predicate { $0.isSynced == false }, sortBy: [.init(\.timestamp, order: .forward)])
        let pending = (try? context.fetch(descriptor)) ?? []

        for record in pending {
            let payload = ConversionPayload(
                id: record.id,
                inputValue: record.inputValue,
                fromUnit: record.fromUnit,
                toUnit: record.toUnit,
                result: record.resultValue,
                timestamp: record.timestamp
            )

            do {
                try await apiClient.logConversion(payload)
                record.isSynced = true
            } catch {
                // Keep pending if offline
                break
            }
        }
    }
}
