extension AcaiaValue {
    public struct Weight {
        public var weight: Double
        public var isStable: Bool

        init(weight: Double, isStable: Bool) {
            self.weight = weight
            self.isStable = isStable
        }
    }
}
