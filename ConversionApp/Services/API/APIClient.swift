import Foundation

struct APIClient {
    var baseURL: URL = URL(string: "http://localhost:8000")!

    func logConversion(_ payload: ConversionPayload) async throws {
        let url = baseURL.appendingPathComponent("convert")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    func fetchHistory() async throws -> [ConversionPayload] {
        let url = baseURL.appendingPathComponent("history")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([ConversionPayload].self, from: data)
    }

    func clearHistory() async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("history"))
        request.httpMethod = "DELETE"
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

struct ConversionPayload: Codable, Identifiable {
    var id: UUID
    var inputValue: Double
    var fromUnit: String
    var toUnit: String
    var result: Double
    var timestamp: Date

    init(id: UUID = UUID(), inputValue: Double, fromUnit: ConversionUnit, toUnit: ConversionUnit, result: Double, timestamp: Date = .now) {
        self.id = id
        self.inputValue = inputValue
        self.fromUnit = fromUnit.rawValue
        self.toUnit = toUnit.rawValue
        self.result = result
        self.timestamp = timestamp
    }
}
