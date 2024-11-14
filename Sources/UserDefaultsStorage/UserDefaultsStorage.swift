//
//  UserDefaultsStorage.swift
//  UserDefaultsStorage
//
//  Created by 风起兮 on 2024-11-14.
//

import SwiftUI
import Combine

@MainActor private let sync = UserDefaultsStorageSync.shared

@propertyWrapper
@MainActor
public struct UserDefaultsStorage<Value>: DynamicProperty {
    @ObservedObject private var object: UserDefaultsStorageObject<Value>

    public var wrappedValue: Value {
        get { object.value }
        nonmutating set { object.value = newValue }
    }

    public var projectedValue: Binding<Value> {
        Binding { object.value } set: { object.value = $0 }
    }

    public init(keyName key: String, syncGet: @escaping () -> Value, syncSet: @escaping (Value) -> Void) {
        self.object = UserDefaultsStorageObject(key: key, syncGet: syncGet, syncSet: syncSet)
    }

    public static subscript<OuterSelf: ObservableObject>(
        _enclosingInstance instance: OuterSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<OuterSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<OuterSelf, Self>
    ) -> Value {
        get {
            instance[keyPath: storageKeyPath].object.keyObserver.enclosingObjectWillChange = instance.objectWillChange as? ObservableObjectPublisher
            return instance[keyPath: storageKeyPath].wrappedValue
        }
        set {
            instance[keyPath: storageKeyPath].wrappedValue = newValue
        }
    }
}

@MainActor
internal class KeyObserver {
    weak var storageObjectWillChange: ObservableObjectPublisher?
    weak var enclosingObjectWillChange: ObservableObjectPublisher?

    func keyChanged() {
        storageObjectWillChange?.send()
        enclosingObjectWillChange?.send()
    }
}

@MainActor
internal class UserDefaultsStorageObject<Value>: ObservableObject {
    private let key: String
    private let syncGet: () -> Value
    private let syncSet: (Value) -> Void

    let keyObserver = KeyObserver()

    var value: Value {
        get { syncGet() }
        set {
            syncSet(newValue)
            sync.notifyObservers(for: key)
            sync.synchronize()
        }
    }

    init(key: String, syncGet: @escaping () -> Value, syncSet: @escaping (Value) -> Void) {
        self.key = key
        self.syncGet = syncGet
        self.syncSet = syncSet

        keyObserver.storageObjectWillChange = objectWillChange
        sync.addObserver(keyObserver, key: key)
    }

    deinit {
        Task { @MainActor [keyObserver] in
            sync.removeObserver(keyObserver)
        }
    }
}

extension UserDefaultsStorage : Sendable where Value : Sendable {
}

extension UserDefaultsStorage where Value == Bool {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.bool(for: key) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage where Value == Int {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.int(for: key) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage where Value == Double {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.double(for: key) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage where Value == String {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.string(for: key) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage where Value == URL {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.url(for: key) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage where Value == Date {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.date(for: key) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage where Value == Data {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.data(for: key) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage where Value: RawRepresentable, Value.RawValue == Int {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.int(for: key).flatMap(Value.init) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue.rawValue, for: key) })
    }
}

extension UserDefaultsStorage where Value: RawRepresentable, Value.RawValue == String {
    public init(wrappedValue: Value, _ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.string(for: key).flatMap(Value.init) ?? wrappedValue },
            syncSet: { newValue in sync.set(newValue.rawValue, for: key) })
    }
}

extension UserDefaultsStorage where Value == Bool? {
    public init(_ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.bool(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage where Value == Int? {
    public init(_ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.int(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage where Value == Double? {
    public init(_ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.double(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage where Value == String? {
    public init(_ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.string(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage where Value == URL? {
    public init(_ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.url(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage where Value == Date? {
    public init(_ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.date(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage where Value == Data? {
    public init(_ key: String) {
        self.init(
            keyName: key,
            syncGet: { sync.data(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage {
    public init<R>(_ key: String) where Value == R?, R: RawRepresentable, R.RawValue == String {
        self.init(
            keyName: key,
            syncGet: { sync.rawRepresentable(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}

extension UserDefaultsStorage {
    public init<R>(_ key: String) where Value == R?, R: RawRepresentable, R.RawValue == Int {
        self.init(
            keyName: key,
            syncGet: { sync.rawRepresentable(for: key) },
            syncSet: { newValue in sync.set(newValue, for: key) })
    }
}
