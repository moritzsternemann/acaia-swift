extension AcaiaValue {
    public struct Status {
        public enum WeightUnit {
            case grams, ounces
        }

        public enum Mode: UInt8 {
            case weighing
            case dualDisplay
            case timerStartsWithFlow
            case autoTareTimerStartsWithFlow
            case autoTareAutoStartTimer
            case autoTare
            case pourOverAutoStartTimer
        }

        /// The current battery level of the scale.
        public var batteryLevel: Double

        /// Indicates if the timer is currently running.
        public var isTimerRunning: Bool

        /// Grams or ounces.
        public var weightUnit: WeightUnit?

        /// The current weighing mode.
        public var mode: Mode?

        /// The sleep timer setting in minutes, or disabled sleep timer when the value is `nil`.
        public var sleepTimer: Int?

        /// Indicates if the key sound (or beep) is turned on.
        public var isBeepOn: Bool

        /// Indicates if the scale is in high or default resolution mode.
        public var isResolutionHigh: Bool

        init(
            batteryLevel: Double,
            isTimerRunning: Bool,
            weightUnit: WeightUnit?,
            mode: Mode?,
            sleepTimer: Int?,
            isBeepOn: Bool,
            isResolutionHigh: Bool
        ) {
            self.batteryLevel = batteryLevel
            self.isTimerRunning = isTimerRunning
            self.weightUnit = weightUnit
            self.mode = mode
            self.sleepTimer = sleepTimer
            self.isBeepOn = isBeepOn
            self.isResolutionHigh = isResolutionHigh
        }
    }
}
