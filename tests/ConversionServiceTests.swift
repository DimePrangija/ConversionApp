import XCTest
@testable import ConversionApp

final class ConversionServiceTests: XCTestCase {
    func testPoundsToKilogramsConversion() {
        let service = ConversionService()
        let result = service.convert(value: 10, direction: .poundsToKilograms, decimals: 2)
        XCTAssertEqual(result, 4.54, accuracy: 0.01)
    }

    func testKilogramsToPoundsConversion() {
        let service = ConversionService()
        let result = service.convert(value: 5, direction: .kilogramsToPounds, decimals: 3)
        XCTAssertEqual(result, 11.023, accuracy: 0.001)
    }

    func testRounding() {
        let service = ConversionService()
        let result = service.convert(value: 1, direction: .poundsToKilograms, decimals: 4)
        XCTAssertEqual(result, 0.4536, accuracy: 0.0001)
    }
}
