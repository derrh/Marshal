//
//  M A R S H A L
//
//       ()
//       /\
//  ()--'  '--()
//    `.    .'
//     / .. \
//    ()'  '()
//
//


import Foundation


// MARK: - <| Operator

infix operator <| { associativity left precedence 150 }

public func <| <A: ValueType>(marshaled: Marshaled, key: String) throws -> A {
    return try marshaled.value(key: key)
}
public func <| <A: ValueType>(marshaled: Marshaled, key: String) throws -> A? {
    return try marshaled.value(key: key)
}
public func <| <A: ValueType>(marshaled: Marshaled, key: String) throws -> [A] {
    return try marshaled.value(key: key)
}
public func <| <A: ValueType>(marshaled: Marshaled, key: String) throws -> [A]? {
    return try marshaled.value(key: key)
}
public func <| <A: RawRepresentable where A.RawValue: ValueType>(marshaled: Marshaled, key: String) throws -> A {
    return try marshaled.value(key: key)
}
public func <| <A: RawRepresentable where A.RawValue: ValueType>(marshaled: Marshaled, key: String) throws -> A? {
    return try marshaled.value(key: key)
}
public func <| <A: RawRepresentable where A.RawValue: ValueType>(marshaled: Marshaled, key: String) throws -> [A] {
    return try marshaled.value(key: key)
}
public func <| <A: RawRepresentable where A.RawValue: ValueType>(marshaled: Marshaled, key: String) throws -> [A]? {
    return try marshaled.value(key: key)
}
