//
//  EqueryEncoder.swift
//  DataLayer
//
//  Created by USOV Vasily on 14.01.2025.
//

import Foundation

/// Кодировщик паарметро в коллекцию URLQueryItem
/// 
/// Используется, когда необходимо закодировать переданную модель в QueryItem параметры URL
public class QueryEncoder {
    public func encode<T: Encodable>(_ value: T) throws -> [URLQueryItem] {
        let encoding = QueryEncoding()
        try value.encode(to: encoding)
        return encoding.data.items
    }
}

private struct QueryEncoding: Encoder {
    fileprivate final class Data {
        private(set) var items: [URLQueryItem] = []

        func encode(key codingKey: [CodingKey], value: String) {
            let key = codingKey.map(\.stringValue).joined(separator: ".")
            let item = URLQueryItem(name: key, value: value)
            items.append(item)
        }
    }

    fileprivate var data: Data

    init(to encodedData: Data = Data()) {
        data = encodedData
    }

    var codingPath: [CodingKey] = []

    let userInfo: [CodingUserInfoKey: Any] = [:]

    func container<Key: CodingKey>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> {
        var container = QueryKeyedEncoding<Key>(to: data)
        container.codingPath = codingPath
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        var container = QueryUnkeyedEncoding(to: data)
        container.codingPath = codingPath
        return container
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        var container = QuerySingleValueEncoding(to: data)
        container.codingPath = codingPath
        return container
    }
}

private struct QueryKeyedEncoding<Key: CodingKey>: KeyedEncodingContainerProtocol {
    private let data: QueryEncoding.Data

    init(to data: QueryEncoding.Data) {
        self.data = data
    }

    var codingPath: [CodingKey] = []

    mutating func encodeNil(forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: "nil")
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value.description)
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value.description)
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value.description)
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value.description)
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value.description)
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value.description)
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value.description)
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value.description)
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value.description)
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value.description)
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value.description)
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value.description)
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: value.description)
    }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        var stringsEncoding = QueryEncoding(to: data)
        stringsEncoding.codingPath.append(key)
        try value.encode(to: stringsEncoding)
    }

    mutating func nestedContainer<NestedKey: CodingKey>(
        keyedBy _: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> {
        var container = QueryKeyedEncoding<NestedKey>(to: data)
        container.codingPath = codingPath + [key]
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        var container = QueryUnkeyedEncoding(to: data)
        container.codingPath = codingPath + [key]
        return container
    }

    mutating func superEncoder() -> Encoder {
        let superKey = Key(stringValue: "super")!
        return superEncoder(forKey: superKey)
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        var stringsEncoding = QueryEncoding(to: data)
        stringsEncoding.codingPath = codingPath + [key]
        return stringsEncoding
    }
}

private struct QueryUnkeyedEncoding: UnkeyedEncodingContainer {
    private let data: QueryEncoding.Data

    init(to data: QueryEncoding.Data) {
        self.data = data
    }

    var codingPath: [CodingKey] = []

    private(set) var count: Int = 0

    private mutating func nextIndexedKey() -> CodingKey {
        let nextCodingKey = IndexedCodingKey(intValue: count)!
        count += 1
        return nextCodingKey
    }

    private struct IndexedCodingKey: CodingKey {
        let intValue: Int?
        let stringValue: String

        init?(intValue: Int) {
            self.intValue = intValue
            stringValue = intValue.description
        }

        init?(stringValue _: String) {
            nil
        }
    }

    mutating func encodeNil() throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: "nil")
    }

    mutating func encode(_ value: Bool) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }

    mutating func encode(_ value: String) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value)
    }

    mutating func encode(_ value: Double) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }

    mutating func encode(_ value: Float) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }

    mutating func encode(_ value: Int) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }

    mutating func encode(_ value: Int8) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }

    mutating func encode(_ value: Int16) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }

    mutating func encode(_ value: Int32) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }

    mutating func encode(_ value: Int64) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }

    mutating func encode(_ value: UInt) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }

    mutating func encode(_ value: UInt8) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }

    mutating func encode(_ value: UInt16) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }

    mutating func encode(_ value: UInt32) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }

    mutating func encode(_ value: UInt64) throws {
        data.encode(key: codingPath + [nextIndexedKey()], value: value.description)
    }

    mutating func encode<T: Encodable>(_ value: T) throws {
        var stringsEncoding = QueryEncoding(to: data)
        stringsEncoding.codingPath = codingPath + [nextIndexedKey()]
        try value.encode(to: stringsEncoding)
    }

    mutating func nestedContainer<NestedKey: CodingKey>(
        keyedBy _: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> {
        var container = QueryKeyedEncoding<NestedKey>(to: data)
        container.codingPath = codingPath + [nextIndexedKey()]
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        var container = QueryUnkeyedEncoding(to: data)
        container.codingPath = codingPath + [nextIndexedKey()]
        return container
    }

    mutating func superEncoder() -> Encoder {
        var stringsEncoding = QueryEncoding(to: data)
        stringsEncoding.codingPath.append(nextIndexedKey())
        return stringsEncoding
    }
}

private struct QuerySingleValueEncoding: SingleValueEncodingContainer {
    private let data: QueryEncoding.Data

    init(to data: QueryEncoding.Data) {
        self.data = data
    }

    var codingPath: [CodingKey] = []

    mutating func encodeNil() throws {
        data.encode(key: codingPath, value: "nil")
    }

    mutating func encode(_ value: Bool) throws {
        data.encode(key: codingPath, value: value.description)
    }

    mutating func encode(_ value: String) throws {
        data.encode(key: codingPath, value: value)
    }

    mutating func encode(_ value: Double) throws {
        data.encode(key: codingPath, value: value.description)
    }

    mutating func encode(_ value: Float) throws {
        data.encode(key: codingPath, value: value.description)
    }

    mutating func encode(_ value: Int) throws {
        data.encode(key: codingPath, value: value.description)
    }

    mutating func encode(_ value: Int8) throws {
        data.encode(key: codingPath, value: value.description)
    }

    mutating func encode(_ value: Int16) throws {
        data.encode(key: codingPath, value: value.description)
    }

    mutating func encode(_ value: Int32) throws {
        data.encode(key: codingPath, value: value.description)
    }

    mutating func encode(_ value: Int64) throws {
        data.encode(key: codingPath, value: value.description)
    }

    mutating func encode(_ value: UInt) throws {
        data.encode(key: codingPath, value: value.description)
    }

    mutating func encode(_ value: UInt8) throws {
        data.encode(key: codingPath, value: value.description)
    }

    mutating func encode(_ value: UInt16) throws {
        data.encode(key: codingPath, value: value.description)
    }

    mutating func encode(_ value: UInt32) throws {
        data.encode(key: codingPath, value: value.description)
    }

    mutating func encode(_ value: UInt64) throws {
        data.encode(key: codingPath, value: value.description)
    }

    mutating func encode<T: Encodable>(_ value: T) throws {
        var stringsEncoding = QueryEncoding(to: data)
        stringsEncoding.codingPath = codingPath
        try value.encode(to: stringsEncoding)
    }
}
