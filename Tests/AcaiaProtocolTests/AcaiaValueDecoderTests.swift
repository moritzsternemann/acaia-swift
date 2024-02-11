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
        let status = assertDecodeScaleStatus(values[0])

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

    func testDecodeWeightEvent() throws {
        // Arrange
        let data = payload(type: 0x0C, [0x05, 0, 0, 0, 0, 0, 0])

        // Act
        let values = try decoder.decodeValues(from: data)

        // Assert
        XCTAssertEqual(values.count, 1)
        let weight = assertDecodeWeight(values[0])

        XCTAssertEqual(weight, WeigthValue(
            weight: 0.0,
            isStable: true
        ))
    }

    private func payload(type: UInt8, _ payload: [UInt8]) -> [UInt8] {
        let payloadForChecksum = [UInt8(payload.count + 1)] + payload
        let checksum = AcaiaChecksum.compute(for: payloadForChecksum)
        return [0xEF, 0xDD, type] + payloadForChecksum + [checksum.even, checksum.odd]
    }

    private func assertDecodeScaleStatus(_ value: AcaiaValue, file: StaticString = #file, line: UInt = #line) -> ScaleStatus {
        guard case let .scaleStatus(status) = value else {
            XCTFail("expected to decode .scaleStatus value")
            fatalError()
        }

        return status
    }

    private func assertDecodeWeight(_ value: AcaiaValue, file: StaticString = #file, line: UInt = #line) -> WeigthValue {
        guard case let .weight(weight) = value else {
            XCTFail("expected to decode .weight value")
            fatalError()
        }

        return weight
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
