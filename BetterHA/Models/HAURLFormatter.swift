import Foundation

enum HAURLFormatter {
    static func format(_ raw: String) -> String? {
        var value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return nil }

        while value.hasSuffix("/") {
            value.removeLast()
        }
        guard !value.isEmpty else { return nil }

        let lowercased = value.lowercased()
        if !lowercased.hasPrefix("http://") && !lowercased.hasPrefix("https://") {
            value = "http://" + value
        }

        guard let schemeRange = value.range(of: "://") else { return value }
        let afterScheme = value[schemeRange.upperBound...]
        if !afterScheme.contains(":") {
            value += ":8123"
        }

        return value
    }
}
