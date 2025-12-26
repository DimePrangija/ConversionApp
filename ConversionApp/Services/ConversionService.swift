import Foundation

struct ConversionService {
    static let poundsToKilogramsFactor = 0.453_592_37

    func convert(value: Double, direction: ConversionDirection, decimals: Int) -> Double {
        let rawResult: Double
        switch direction {
        case .poundsToKilograms:
            rawResult = value * Self.poundsToKilogramsFactor
        case .kilogramsToPounds:
            rawResult = value / Self.poundsToKilogramsFactor
        }
        return rawResult.rounded(toPlaces: decimals)
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        guard places >= 0 else { return self }
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
