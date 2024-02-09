struct AcaiaRawValue {
    enum ValueType {
        case scaleStatus
        case event

        init?(_ type: UInt8) {
            switch type {
            // 0x07: maybe timer update?
            // sample payload: [ef dd 07 07] 02 19 01 00 0e 01 [21 11]
            case 0x08:
                self = .scaleStatus
            case 0x0C:
                self = .event
            default:
                return nil
            }
        }
    }

    var type: ValueType
    var payload: [UInt8]
}
