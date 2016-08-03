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


// MARK: - Types

public typealias MarshalDictionary = [String: AnyObject]


// MARK: - Dictionary Extensions

extension Dictionary: Marshaled {
    public func any(optionalKey key: KeyType) -> Any? {
        guard let aKey = key as? Key else { return nil }
        
        return self[aKey]
    }
}

extension NSDictionary: ValueType { }

extension NSDictionary: Marshaled {
    public func any(requiredKey key: KeyType) throws -> Any {
        let value:Any
        if key.dynamicType.keyTypeSeparator == "." {
            // `valueForKeyPath` is more efficient. Use it if possible.
            guard let v = self.value(forKeyPath: key.stringValue) else {
                throw MarshalError.keyNotFound(key: key)
            }
            value = v
        }
        else {
            let pathComponents = key.split()
            var accumulator: Any = self

            for component in pathComponents {
                if let componentData = accumulator as? Marshaled, let v = componentData.any(optionalKey: component) {
                    accumulator = v
                    continue
                }
                throw MarshalError.keyNotFound(key: key.stringValue)
            }
            value = accumulator
        }

        if let _ = value as? NSNull {
            throw MarshalError.nullValue(key: key)
        }

        return value
    }

    public func any(optionalKey key: KeyType) -> Any? {
        guard let aKey = key as? Key else { return nil }
        
        return self[aKey]
    }
}
