import Foundation
import Turbo

/// Path Configurationの拡張
/// RailsサーバーからJSON設定を取得し、URLごとの振る舞いを定義
extension PathConfiguration {
    /// URL に対応するプロパティを取得
    public func properties(for url: URL) -> PathProperties {
        guard let rule = rules.first(where: { $0.matches(url) }) else {
            return PathProperties(properties: [:])
        }

        return rule.properties
    }

    /// Path Rule の拡張
    private var rules: [PathRule] {
        return self.settings["rules"] as? [PathRule] ?? []
    }
}

/// Path Rule 構造体
public struct PathRule: Decodable {
    let patterns: [String]
    let properties: PathProperties

    func matches(_ url: URL) -> Bool {
        let path = url.path

        for pattern in patterns {
            // ワイルドカードと正規表現のサポート
            let regexPattern = pattern
                .replacingOccurrences(of: "*", with: "[^/]*")
                .replacingOccurrences(of: "\\d+", with: "[0-9]+")

            if let regex = try? NSRegularExpression(pattern: "^\(regexPattern)$", options: []),
               regex.firstMatch(in: path, options: [], range: NSRange(location: 0, length: path.utf16.count)) != nil {
                return true
            }
        }

        return false
    }
}

/// Path Properties 構造体
public struct PathProperties: Decodable {
    let properties: [String: Any]

    public init(properties: [String: Any]) {
        self.properties = properties
    }

    // Decodable conformance
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        properties = try container.decode([String: Any].self)
    }

    // プロパティへのアクセサー
    subscript(key: String) -> Any? {
        return properties[key]
    }

    var context: String? {
        return properties["context"] as? String
    }

    var presentation: String? {
        return properties["presentation"] as? String
    }

    var pullToRefreshEnabled: Bool {
        return properties["pull_to_refresh_enabled"] as? Bool ?? false
    }
}

/// Dictionary から Any をデコード可能にする拡張
extension KeyedDecodingContainer {
    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }

    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }

    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()

        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }

        return dictionary
    }
}

extension UnkeyedDecodingContainer {
    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []

        while isAtEnd == false {
            if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let value = try? decode(Int.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }

        return array
    }

    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}

/// JSON Coding Keys
struct JSONCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}
