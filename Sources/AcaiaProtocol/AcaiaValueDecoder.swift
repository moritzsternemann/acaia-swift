import Darwin

public final class AcaiaValueDecoder {
    public init() {}

    public func decodeValues(from data: [UInt8]) throws -> [AcaiaValue] {
        let rawValue = try decodeRawValue(from: data)

        switch rawValue.type {
        case .scaleStatus:
            let status = decodeScaleStatus(from: rawValue.payload)
            return [.scaleStatus(status)]
        case .event:
            return try decodeEvent(from: rawValue.payload)
        }
    }

    // Decode the raw value bytes, verifying length, checksum, and known value type
    private func decodeRawValue(from data: [UInt8]) throws -> AcaiaRawValue {
        // Check for minimum packet length: 2x header, type, length, 2x checksum
        guard data.count >= 6 else {
            throw AcaiaValueDecodingError.notEnoughData
        }

        guard data[0] == Constants.headerByte1, data[1] == Constants.headerByte2 else {
            throw AcaiaValueDecodingError.invalidHeader
        }

        let type = data[2]
        let payloadLength = Int(data[3])

        // header1, header2, type + payload + checksum1, checksum2
        guard data.count >= (3 + payloadLength + 2) else {
            throw AcaiaValueDecodingError.notEnoughData
        }

        let payloadForChecksum = data[3..<(3 + payloadLength)]
        let packetChecksum = (data[3 + payloadLength + 1], data[3 + payloadLength])
        guard AcaiaChecksum.verify(for: payloadForChecksum, reference: packetChecksum) else {
            throw AcaiaValueDecodingError.invalidChecksum
        }

        guard let valueType = AcaiaRawValue.ValueType(type) else {
            throw AcaiaUnknownPacketTypeError(type: type, payload: Array(payloadForChecksum.dropFirst()))
        }

        return AcaiaRawValue(
            type: valueType,
            payload: Array(payloadForChecksum.dropFirst()) // drop length byte
        )
    }
}

extension AcaiaValueDecoder {
    private func decodeScaleStatus(from payload: [UInt8]) -> AcaiaValue.Status {
        precondition(payload.count == 8, "the scale status payload is expected to be 8 bytes")

        // [0], lower nibble: battery level
        let batteryLevel = Double(payload[0] & 0x7F) / 100.0

        // [0], upper nibble: msb timer, other bits unknown
        let isTimerRunning = payload[0] & 0x80 == 0x80

        // [1]: weight unit
        // TODO: fallback or error?
        let weightUnit: AcaiaValue.Status.WeightUnit? = switch payload[1] {
        case 2: .grams
        case 5: .ounces
        default: nil
        }

        // [2]: mode
        // TODO: fallback or error?
        let mode = AcaiaValue.Status.Mode(rawValue: payload[2])

        // [3]: sleep timer
        let sleepTimer: Int? = switch payload[3] {
        case 0: nil
        case 1: 5
        case 2: 10
        case 3: 20
        case 4: 30
        case 5: 60
        default: nil
        }

        // [4]: unknown

        // [5]: beep on
        let isBeepOn = payload[5] == 1

        // [6]: weighing resolution high or default
        let isResolutionHigh = !(payload[6] == 1)

        // [7]: unknown

        return AcaiaValue.Status(
            batteryLevel: batteryLevel,
            isTimerRunning: isTimerRunning,
            weightUnit: weightUnit,
            mode: mode,
            sleepTimer: sleepTimer,
            isBeepOn: isBeepOn,
            isResolutionHigh: isResolutionHigh
        )
    }
}

extension AcaiaValueDecoder {
    private func decodeEvent(from payload: [UInt8]) throws -> [AcaiaValue] {
        var payload = payload

        // a single event can have multiple value-updates, e.g.
        // [05 00 00 00 00 01 00] [07 00 00 02] (weight + timer)
        // [08 08] [05 00 00 00 00 01 00] [07 00 00 02] (action + weight + timer)

        var values: [AcaiaValue] = []
        while !payload.isEmpty {
            let type = payload.removeFirst()

            switch type {
            case 0x05: // weight
                guard let weightPayload = payload.popFirst(6) else {
                    throw AcaiaValueDecodingError.notEnoughData
                }
                let weight = decodeWeightValue(from: weightPayload)
                values.append(.weight(weight))
             case 0x06: // battery level
                guard let batteryLevelPayload = payload.popFirst() else {
                    throw AcaiaValueDecodingError.notEnoughData
                }
                let batteryLevel = decodeBatteryLevelValue(from: batteryLevelPayload)
                values.append(.batteryLevel(batteryLevel))
            case 0x07: // timer
                guard let timerPayload = payload.popFirst(3) else {
                    throw AcaiaValueDecodingError.notEnoughData
                }
                let timer = decodeTimerValue(from: timerPayload)
                values.append(.timer(timer))
            case 0x08: // action
                guard let actionPayload = payload.popFirst() else {
                    throw AcaiaValueDecodingError.notEnoughData
                }
                let action = try decodeActionValue(from: actionPayload)
                values.append(.action(action))
            default:
                throw AcaiaUnknownEventTypeError(type: type, payload: payload)
            }
        }

        return values
    }

    private func decodeWeightValue(from payload: [UInt8]) -> AcaiaValue.Weight {
        precondition(payload.count == 6, "the weight event payload is expected to be 6 bytes")

        let wholeNumberValue = [
            Int(payload[2]) << 16,
            Int(payload[1]) << 8,
            Int(payload[0])
        ].reduce(0, +)

        // [3]: unknown

        let valueMagnitude = payload[4]
        precondition(valueMagnitude <= 4, "unexpected value magnitude: \(valueMagnitude)")
        
        let unsignedValue = Double(wholeNumberValue) * pow(10, -Double(valueMagnitude))

        let isStable = payload[5] & 0x01 == 0
        let isValueNegative = payload[5] & 0x02 == 0x02

        return AcaiaValue.Weight(
            weight: isValueNegative ? unsignedValue * -1 : unsignedValue,
            isStable: isStable
        )
    }

    private func decodeBatteryLevelValue(from payload: UInt8) -> Double {
        Double(payload) / 100.0
    }

    private func decodeTimerValue(from payload: [UInt8]) -> Double {
        precondition(payload.count == 3, "the time payload is expected to be 3 bytes")

        return [
            Double(payload[0]) * 60.0,
            Double(payload[1]),
            Double(payload[2]) / 10.0
        ].reduce(0, +) - 0.2 // 0.2 seems to be some kind of transit delay
    }

    private func decodeActionValue(from action: UInt8) throws -> AcaiaValue.Action {
        return switch action {
        case 0x08: .startTimer
        case 0x09: .resetTimer
        case 0x0A: .pauseTimer
        default:
            throw AcaiaUnknownActionError(action: action)
        }
    }
}

public enum AcaiaValueDecodingError: Error {
    case notEnoughData
    case invalidHeader
    case invalidChecksum
}

public struct AcaiaUnknownPacketTypeError: Error {
    public let type: UInt8
    public let payload: [UInt8]
}

public struct AcaiaUnknownEventTypeError: Error {
    public let type: UInt8
    public let payload: [UInt8]
}

public struct AcaiaUnknownActionError: Error {
    public let action: UInt8
}
