struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b1
    static let alien: UInt32 = 0b10
    static let playerLaser: UInt32 = 0b100
    static let alienLaser: UInt32 = 0b1000
    static let block: UInt32 = 0b10000
    static let extra: UInt32 = 0b100000
}
