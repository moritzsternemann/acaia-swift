public struct AcaiaCommand {
    enum CommandType {
        case heartbeat
        case authenticate
        case notificationRequest

        case statusRequest
        case tare

        var rawValue: UInt8 {
            return switch self {
            case .heartbeat: 0x00
            case .authenticate: 0x0B
            case .notificationRequest: 0x0C
            case .statusRequest: 0x06
            case .tare: 0x04
            }
        }
    }

    var type: CommandType
    var payload: [UInt8]

    init(type: CommandType, payload: [UInt8]) {
        self.type = type
        self.payload = payload
    }
}

extension AcaiaCommand {
    public static func heartbeat() -> AcaiaCommand {
        AcaiaCommand(type: .heartbeat, payload: [0x02, 0x00])
    }

    public static func authenticate() -> AcaiaCommand {
        // The payload is the "password" 012345678901234
        AcaiaCommand(type: .authenticate, payload: [0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34])

        // Older scales require a different payload [0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d]
    }

    public static func notificationRequest() -> AcaiaCommand {
        // Other implementations include a payload that might configure
        // which notifications are requested. However, no configurations
        // I tried enabled, disabled, or changed any notifications.
        // Maybe this functionality is only present on older scales.

        // 0x01 is just the payload length (including the length byte itself)
        AcaiaCommand(type: .notificationRequest, payload: [0x01])
    }
}

extension AcaiaCommand {
    public static func statusRequest() -> AcaiaCommand {
        // Other implementations send 16 0-bytes as the payload. Not sure if
        // this is required or if the payload encodes any request options.
        // Sending no payload results in a response with the same information.
        AcaiaCommand(type: .statusRequest, payload: [])
    }

    public static func tare() -> AcaiaCommand {
        // Didn't notice any different behavior with different payloads.
        // It has to be a single byte though.
        AcaiaCommand(type: .tare, payload: [0x00])
    }
}
