public struct AcaiaCommand {
    enum CommandType {
        case heartbeat
        case authenticate

        var rawValue: UInt8 {
            return switch self {
            case .heartbeat: 0x00
            case .authenticate: 0x0B
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
}
