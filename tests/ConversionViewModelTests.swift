import XCTest
@testable import ConversionApp

@MainActor
final class ConversionViewModelTests: XCTestCase {
    func testSwapUnitsUpdatesDirectionAndUserSettings() {
        let userSettings = UserSettings()
        userSettings.defaultDirection = .poundsToKilograms
        let haptics = MockHapticsService()
        let viewModel = ConversionViewModel(haptics: haptics, userSettings: userSettings, apiClient: APIClient())

        viewModel.swapUnits()

        XCTAssertEqual(viewModel.direction, .kilogramsToPounds)
        XCTAssertEqual(userSettings.defaultDirection, .kilogramsToPounds)
        XCTAssertTrue(haptics.selectionTriggered)
    }

    func testUpdatingDecimalPlacesClampsAndReformatsResult() async {
        let userSettings = UserSettings()
        userSettings.defaultDirection = .poundsToKilograms
        userSettings.decimalPlaces = 2
        let viewModel = ConversionViewModel(userSettings: userSettings, apiClient: APIClient())

        viewModel.inputText = "2"
        await waitForConversionToComplete()

        viewModel.updateDecimalPlaces(6)
        await waitForConversionToComplete()

        XCTAssertEqual(viewModel.decimalPlaces, 4)
        XCTAssertEqual(viewModel.resultText, "0.9072")
    }

    private func waitForConversionToComplete() async {
        try? await Task.sleep(nanoseconds: 400_000_000)
        await Task.yield()
    }
}

private final class MockHapticsService: HapticsService {
    private(set) var selectionTriggered = false

    override func selectionChanged(enabled: Bool) {
        if enabled { selectionTriggered = true }
    }

    override func success(enabled: Bool) { }
}
