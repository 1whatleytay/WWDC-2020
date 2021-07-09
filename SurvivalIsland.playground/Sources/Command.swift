import SpriteKit
import Foundation

public enum Target {
    case wall
    case enemy
    case gap
    case invalid
}

public enum Command {
    case check(Target)
    case move
    case jump
    case attack
    case invalid
}

// I thought you could package this up with the enum, maybe not?
public func getName(for command: Command) -> String {
    switch (command) {
    case .check(let target): return "Sees \(getName(for: target))"
    case .move: return "Move"
    case .jump: return "Jump"
    case .attack: return "Attack"
    default: return "Invalid"
    }
}

public func getName(for target: Target) -> String {
    switch (target) {
    case .wall: return "Wall"
    case .enemy: return "Enemy"
    case .gap: return "Cliff"
    default: return "?"
    }
}

// too pressed for time to clean this up
public func getColors(for command: Command) -> (background: NSColor, foreground: NSColor) {
    switch(command) {
    case .check:
        return (
            background: NSColor(red: 0.21, green: 0.58, blue: 0.43, alpha: 1.0),
            foreground: NSColor(red: 0.42, green: 0.74, blue: 0.43, alpha: 1.0)
        )
    case .move:
        return (
            background: NSColor(red: 0.67, green: 0.19, blue: 0.19, alpha: 1.0),
            foreground: NSColor(red: 0.74, green: 0.41, blue: 0.32, alpha: 1.0)
        )
    case .jump:
        return (
            background: NSColor(red: 0.87, green: 0.44, blue: 0.14, alpha: 1.0),
            foreground: NSColor(red: 0.90, green: 0.61, blue: 0.27, alpha: 1.0)
        )
    case .attack:
        return (
            background: NSColor(red: 0.35, green: 0.43, blue: 0.88, alpha: 1.0),
            foreground: NSColor(red: 0.49, green: 0.70, blue: 0.94, alpha: 1.0)
        )
    default:
        return (
            background: NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            foreground: NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        )
    }
}
