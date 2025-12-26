import Foundation
import SwiftData

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var filterDirection: ConversionDirection?
    @Published var searchText: String = ""

    private let apiClient: APIClient
    private let syncService: SyncService

    init(apiClient: APIClient, syncService: SyncService = SyncService()) {
        self.apiClient = apiClient
        self.syncService = syncService
    }

    func matchesFilter(_ record: ConversionRecord) -> Bool {
        if let filterDirection, record.direction != filterDirection {
            return false
        }

        if searchText.isEmpty { return true }

        let haystack = "\(record.inputValue) \(record.resultValue) \(record.direction.label)".lowercased()
        return haystack.contains(searchText.lowercased())
    }

    func delete(_ record: ConversionRecord, context: ModelContext) {
        context.delete(record)
    }

    func clearAll(context: ModelContext) async {
        let descriptor = FetchDescriptor<ConversionRecord>()
        if let records = try? context.fetch(descriptor) {
            records.forEach { context.delete($0) }
        }
        do { try await apiClient.clearHistory() } catch { }
    }

    func refreshSync(context: ModelContext) async {
        await syncService.syncPendingRecords(context: context, apiClient: apiClient)
    }
}
