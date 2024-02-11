import XCTest
@testable import AcaiaProtocol

final class AcaiaValueDecoderTests: XCTestCase {
    private let decoder = AcaiaValueDecoder()

    func testDecodeStatus() throws {
        // Arrange
        let data = payload(type: 0x08, [0, 0, 0, 0, 0, 0, 0, 0])

        // Act
        let values = try decoder.decodeValues(from: data)

        // Assert
        XCTAssertEqual(values.count, 1)
        guard case let .scaleStatus(status) = values[0] else {
            XCTFail("expected to decode .scaleStatus value")
            return
        }

        XCTAssertEqual(status, ScaleStatus(
            batteryLevel: 0.0,
            isTimerRunning: false,
            weightUnit: nil,
            mode: .weighing,
            sleepTimer: nil,
            isBeepOn: false,
            isResolutionHigh: true
        ))
    }

    func testDecodeWeightValue() throws {
        // Arrange
        let data = payload(type: 0x0C, [0x05, 0, 0, 0, 0, 0, 0])

        // Act
        let values = try decoder.decodeValues(from: data)

        // Assert
        XCTAssertEqual(values.count, 1)
        guard case let .weight(weight) = values[0] else {
            XCTFail("expected to decode .weight value")
            return
        }

        XCTAssertEqual(weight, WeigthValue(
            weight: 0.0,
            isStable: true
        ))
    }

    func testDecodeBatteryLevelValue() throws {
        // Arrange
        let data = payload(type: 0x0C, [0x06, 0x64])

        // Act
        let values = try decoder.decodeValues(from: data)

        // Assert
        XCTAssertEqual(values.count, 1)
        guard case let .batteryLevel(batteryLevel) = values[0] else {
            XCTFail("expected to decode .batteryLevel value")
            return
        }

        XCTAssertEqual(batteryLevel, 1.0)
    }

    func testDecodeTimerValue() throws {
        // Arrange
        let data = payload(type: 0x0C, [0x07, 0x09, 0x3B, 0x02])

        // Act
        let values = try decoder.decodeValues(from: data)

        // Assert
        XCTAssertEqual(values.count, 1)
        guard case let .timer(timer) = values[0] else {
            XCTFail("expected to decode .timer value")
            return
        }

        XCTAssertEqual(timer, 599.0)
    }

    func testDecodeMultipleEventValues() throws {
        // Arrange
        let data = payload(type: 0x0C, [0x05, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x07, 0x00, 0x00, 0x02])

        // Act
        let values = try decoder.decodeValues(from: data)

        // Assert
        XCTAssertEqual(values.count, 2)

        guard case let .weight(weight) = values[0],
              case let .timer(timer) = values[1]
        else {
            XCTFail("expected to decode .weight and .timer values")
            return
        }

        XCTAssertEqual(weight, WeigthValue(
            weight: 0.0,
            isStable: true
        ))
        XCTAssertEqual(timer, 0.0)
    }

    private func payload(type: UInt8, _ payload: [UInt8]) -> [UInt8] {
        let payloadForChecksum = [UInt8(payload.count + 1)] + payload
        let checksum = AcaiaChecksum.compute(for: payloadForChecksum)
        return [0xEF, 0xDD, type] + payloadForChecksum + [checksum.even, checksum.odd]
    }
}

extension ScaleStatus: Equatable {
    public static func ==(lhs: ScaleStatus, rhs: ScaleStatus) -> Bool {
        lhs.batteryLevel == rhs.batteryLevel
            && lhs.isTimerRunning == rhs.isTimerRunning
            && lhs.weightUnit == rhs.weightUnit
            && lhs.mode == rhs.mode
            && lhs.sleepTimer == rhs.sleepTimer
            && lhs.isBeepOn == rhs.isBeepOn
            && lhs.isResolutionHigh && rhs.isResolutionHigh
    }
}

extension WeigthValue: Equatable {
    public static func ==(lhs: WeigthValue, rhs: WeigthValue) -> Bool {
        lhs.weight == rhs.weight
            && lhs.isStable == rhs.isStable
    }
}
