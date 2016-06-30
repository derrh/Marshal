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


public protocol Unmarshaling: ValueType {
    init(object: Marshaled) throws
}

extension Unmarshaling {
    
    public static func value(_ object: Any) throws -> Self {
        guard let marshaledFRD = object as? Marshaled else {
            throw Error.typeMismatch(expected: Marshaled.self, actual: object.dynamicType)
        }
        return try self.init(object: marshaledFRD)
    }
    
}
