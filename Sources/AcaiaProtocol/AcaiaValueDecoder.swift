public final class AcaiaValueDecoder {
    private static let headerByte1: UInt8 = 0xEF
    private static let headerByte2: UInt8 = 0xDD

    public init() {}

    // Decode the raw value bytes, verifying length, checksum, and known value type
    private func decodeRawValue(from data: [UInt8]) throws -> AcaiaRawValue {
        // Check for minimum packet length: 2x header, type, length, 2x checksum
        guard data.count >= 6 else {
            throw DecodingError.notEnoughData
        }

        guard data[0] == Self.headerByte1, data[1] == Self.headerByte2 else {
            throw DecodingError.invalidHeader
        }

        let type = data[2]
        let payloadLength = Int(data[3])

        // header1, header2, type + payload + checksum1, checksum2
        guard data.count >= (3 + payloadLength + 2) else {
            throw DecodingError.notEnoughData
        }

        let payloadForChecksum = data[3..<(3 + payloadLength)]
        let packetChecksum = (data[3 + payloadLength + 1], data[3 + payloadLength])
        guard AcaiaChecksum.verify(for: payloadForChecksum, reference: packetChecksum) else {
            throw DecodingError.invalidChecksum
        }

        guard let valueType = AcaiaRawValue.ValueType(type) else {
            throw DecodingError.unknownType(type)
        }

        return AcaiaRawValue(
            type: valueType,
            payload: Array(payloadForChecksum.dropFirst()) // drop length byte
        )
    }
}

extension AcaiaValueDecoder {
    enum DecodingError: Error {
        case notEnoughData
        case invalidHeader
        case invalidChecksum
        case unknownType(UInt8)
    }
}
