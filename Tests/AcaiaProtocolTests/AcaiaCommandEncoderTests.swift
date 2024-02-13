import XCTest
@testable import AcaiaProtocol

final class AcaiaCommandEncoderTests: XCTestCase {
    private let encoder = AcaiaCommandEncoder()

    func testEncodeHeartbeat() {
        // Act
        let data = encoder.encodeCommand(.heartbeat())

        // Assert
        XCTAssertEqual(data, [0xEF, 0xDD, 0x00, 0x02, 0x00, 0x02, 0x00])
    }

    func testEncodeAuthenticate() {
        // Act
        let data = encoder.encodeCommand(.authenticate())

        // Assert
        XCTAssertEqual(data, [0xEF, 0xDD, 0x0B, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x9A, 0x6D])
    }

    func testEncodeNotificationRequest() {
        // Act
        let data = encoder.encodeCommand(.notificationRequest())

        // Assert
        XCTAssertEqual(data, [0xEF, 0xDD, 0x0C, 0x01, 0x01, 0x00])
    }

    func testEncodeStatusRequest() {
        // Act
        let data = encoder.encodeCommand(.statusRequest())

        // Assert
        XCTAssertEqual(data, [0xEF, 0xDD, 0x06, 0x00, 0x00])
    }

    func testEncodeTare() {
        // Act
        let data = encoder.encodeCommand(.tare())

        // Assert
        XCTAssertEqual(data, [0xEF, 0xDD, 0x04, 0x00, 0x00, 0x00])
    }

    func testEncodeStartTimer() {
        // Act
        let data = encoder.encodeCommand(.startTimer())

        // Assert
        XCTAssertEqual(data, [0xEF, 0xDD, 0x0D, 0x00, 0x00, 0x00, 0x00])
    }

    func testEncodePauseTimer() {
        // Act
        let data = encoder.encodeCommand(.pauseTimer())

        // Assert
        XCTAssertEqual(data, [0xEF, 0xDD, 0x0D, 0x00, 0x02, 0x00, 0x02])
    }

    func testEncodeResetTimer() {
        // Act
        let data = encoder.encodeCommand(.resetTimer())

        // Assert
        XCTAssertEqual(data, [0xEF, 0xDD, 0x0D, 0x00, 0x01, 0x00, 0x01])
    }
}
