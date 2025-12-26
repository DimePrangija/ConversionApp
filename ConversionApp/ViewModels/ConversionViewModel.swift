import Foundation
import SwiftUI
import SwiftData
import UIKit

@MainActor
final class ConversionViewModel: ObservableObject {
    @Published var inputText: String = "" {
        didSet { handleInputChange() }
    }
    @Published var direction: ConversionDirection
    @Published var resultText: String = "--"
    @Published var lastResult: Double?
    @Published var decimalPlaces: Int

    private let debouncer = Debouncer(interval: 0.15)
    private let conversionService: ConversionService
    private let haptics: HapticsService
    private let userSettings: UserSettings
    private let syncService: SyncService
    private let apiClient: APIClient

    init(
        conversionService: ConversionService = ConversionService(),
        haptics: HapticsService = HapticsService(),
        userSettings: UserSettings,
        apiClient: APIClient,
        syncService: SyncService = SyncService()
    ) {
        self.conversionService = conversionService
        self.haptics = haptics
        self.userSettings = userSettings
        self.direction = userSettings.defaultDirection
        self.decimalPlaces = min(max(userSettings.decimalPlaces, 0), 4)
        self.apiClient = apiClient
        self.syncService = syncService
    }

    func swapUnits() {
        direction = direction == .poundsToKilograms ? .kilogramsToPounds : .poundsToKilograms
        userSettings.defaultDirection = direction
        handleInputChange()
        haptics.selectionChanged(enabled: userSettings.hapticsEnabled)
    }

    func updateDecimalPlaces(_ value: Int) {
        decimalPlaces = min(max(value, 0), 4)
        userSettings.decimalPlaces = decimalPlaces
        handleInputChange()
    }

    func handleInputChange() {
        let sanitized = inputText.replacingOccurrences(of: ",", with: ".")
        debouncer.schedule { [weak self] in
            Task { await self?.convertInput(sanitized: sanitized) }
        }
    }

    private func convertInput(sanitized: String) async {
        guard let value = Double(sanitized) else {
            await MainActor.run {
                self.resultText = "--"
                self.lastResult = nil
            }
            return
        }
        let result = conversionService.convert(value: value, direction: direction, decimals: decimalPlaces)
        await MainActor.run {
            self.lastResult = result
            self.resultText = formattedResult(result)
        }
    }

    private func formattedResult(_ result: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = decimalPlaces
        formatter.minimumFractionDigits = decimalPlaces
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: result)) ?? String(result)
    }

    func copyResult() {
        guard let lastResult else { return }
        UIPasteboard.general.string = formattedResult(lastResult)
        haptics.success(enabled: userSettings.hapticsEnabled)
    }

    func saveToHistory(context: ModelContext) async {
        guard let value = Double(inputText.replacingOccurrences(of: ",", with: ".")), let lastResult else { return }
        let record = ConversionRecord(
            inputValue: value,
            fromUnit: direction.from,
            toUnit: direction.to,
            resultValue: lastResult,
            timestamp: .now,
            isSynced: false
        )
        context.insert(record)

        do {
            let payload = ConversionPayload(
                id: record.id,
                inputValue: value,
                fromUnit: direction.from,
                toUnit: direction.to,
                result: lastResult,
                timestamp: record.timestamp
            )
            try await apiClient.logConversion(payload)
            record.isSynced = true
        } catch {
            // remain pending
        }

        await syncService.syncPendingRecords(context: context, apiClient: apiClient)
        haptics.success(enabled: userSettings.hapticsEnabled)
    }
}
