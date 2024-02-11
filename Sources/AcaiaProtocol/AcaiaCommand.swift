public struct AcaiaCommand {
    enum CommandType {
        var rawValue: UInt8 {
            0
        }
    }

    var type: CommandType
    var payload: [UInt8]

    init(type: CommandType, payload: [UInt8]) {
        self.type = type
        self.payload = payload
    }
}
