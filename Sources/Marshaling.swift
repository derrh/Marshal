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

public protocol Marshaling {
    associatedtype MarshalType: Marshaled
    
    func marshal() -> Self.MarshalType
}
