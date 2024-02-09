enum AcaiaChecksum {
    typealias Value = (odd: UInt8, even: UInt8) // TODO: This could just be a UInt16

    static func compute<Data: Sequence>(for data: Data) -> Value where Data.Element == UInt8 {
        var checksumOdd = 0, checksumEven = 0

        for (index, value) in data.enumerated() {
            if index.isMultiple(of: 2) {
                checksumEven += Int(value)
            } else {
                checksumOdd += Int(value)
            }
        }

        return (
            UInt8(checksumOdd & 0xFF),
            UInt8(checksumEven & 0xFF)
        )
    }

    static func verify<Data: Sequence>(for data: Data, reference: Value) -> Bool where Data.Element == UInt8 {
        let computed = compute(for: data)
        return reference == computed
    }
}
