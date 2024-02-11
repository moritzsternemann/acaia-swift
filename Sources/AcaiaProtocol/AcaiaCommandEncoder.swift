public final class AcaiaCommandEncoder {
    public init() {}

    public func encodeCommand(_ command: AcaiaCommand) -> [UInt8] {
        let checksum = AcaiaChecksum.compute(for: command.payload)

        return [
            Constants.headerByte1,
            Constants.headerByte2,
            command.type.rawValue
        ] + command.payload + [checksum.even, checksum.odd]
    }
}
