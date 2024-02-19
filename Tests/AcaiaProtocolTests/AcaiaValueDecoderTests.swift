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

        XCTAssertEqual(status, AcaiaValue.Status(
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

        XCTAssertEqual(weight, AcaiaValue.Weight(
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

    func testDecodeActionValue() throws {
        // Arrange
        let data = payload(type: 0x0C, [0x08, 0x09])

        // Act
        let values = try decoder.decodeValues(from: data)

        // Assert
        XCTAssertEqual(values.count, 1)
        guard case let .action(action) = values[0] else {
            XCTFail("expected to decode .action value")
            return
        }

        XCTAssertEqual(action, .resetTimer)
    }

    func testDecodeMultipleEventValues() throws {
        // Arrange
        let data = payload(type: 0x0C, [0x08, 0x08, 0x05, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x07, 0x00, 0x00, 0x02])

        // Act
        let values = try decoder.decodeValues(from: data)

        // Assert
        XCTAssertEqual(values.count, 3)

        guard case let .action(action) = values[0],
              case let .weight(weight) = values[1],
              case let .timer(timer) = values[2]
        else {
            XCTFail("expected to decode .action, .weight and .timer values")
            return
        }

        XCTAssertEqual(action, .startTimer)
        XCTAssertEqual(weight, AcaiaValue.Weight(
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

extension AcaiaValue.Status: Equatable {
    public static func ==(lhs: AcaiaValue.Status, rhs: AcaiaValue.Status) -> Bool {
        lhs.batteryLevel == rhs.batteryLevel
            && lhs.isTimerRunning == rhs.isTimerRunning
            && lhs.weightUnit == rhs.weightUnit
            && lhs.mode == rhs.mode
            && lhs.sleepTimer == rhs.sleepTimer
            && lhs.isBeepOn == rhs.isBeepOn
            && lhs.isResolutionHigh && rhs.isResolutionHigh
    }
}

extension AcaiaValue.Weight: Equatable {
    public static func ==(lhs: AcaiaValue.Weight, rhs: AcaiaValue.Weight) -> Bool {
        lhs.weight == rhs.weight
            && lhs.isStable == rhs.isStable
    }
}
