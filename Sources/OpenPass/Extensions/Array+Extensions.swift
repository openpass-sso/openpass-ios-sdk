//
//  Array+Extensions.swift
//  
//
//  Created by Brad Leege on 12/14/22.
//

import Foundation

extension Array where Element == UInt8 {

    /// DER Encoding
    ///
    /// https://en.wikipedia.org/wiki/X.690#DER_encoding
    func derEncode(as dataType: UInt8) -> [UInt8] {
        var encodedBytes: [UInt8] = [dataType]
        var numberOfBytes = count
        if numberOfBytes < 128 {
            encodedBytes.append(UInt8(numberOfBytes))
        } else {
            let lengthData = Data(bytes: &numberOfBytes, count: MemoryLayout.size(ofValue: numberOfBytes))
            let lengthBytes = [UInt8](lengthData).filter({ $0 != 0 }).reversed()
            encodedBytes.append(UInt8(truncatingIfNeeded: lengthBytes.count) | 0b10000000)
            encodedBytes.append(contentsOf: lengthBytes)
        }
        encodedBytes.append(contentsOf: self)
        return encodedBytes
    }

}
