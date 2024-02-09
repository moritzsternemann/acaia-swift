import XCTest
@testable import AcaiaProtocol

final class AcaiaValueDecoderTests: XCTestCase {
    private let decoder = AcaiaValueDecoder()

    func testDecodeStatus() throws {
        // Arrange
        let data = payload(type: 0x08, [0, 0, 0, 0, 0, 0, 0, 0])

        // Act
        let value = try decoder.decodeValue(from: data)

        // Assert
        let status = assertDecodeScaleStatus(value)

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
