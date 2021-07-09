import Foundation
import SpriteKit

public class CommandSprite: SKShapeNode {
    var text: SKLabelNode!
    
    var command: Command
    public let rect: CGRect
    
    init(_ newCommand: Command, withRect newRect: CGRect) {
        command = newCommand
        rect = newRect
        
        text = SKLabelNode(text: getName(for: command))
        text.position = CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height / 2)
        text.zPosition = 0.6
        text.fontSize = 24
        text.fontColor = NSColor.black
        text.horizontalAlignmentMode = .center
        text.verticalAlignmentMode = .center
        
        super.init()
        
        path = CGPath(roundedRect: rect, cornerWidth: 5, cornerHeight: 5, transform: nil)
        zPosition = 0.5
        
        let colors = getColors(for: command)
        fillColor = colors.foreground
        strokeColor = colors.background
        lineWidth = 2
        
        addChild(text)
    }
    
    // not going to bother implementing this yet
    required init?(coder decoder: NSCoder) {
        command = .invalid
        rect = CGRect()
        
        super.init(coder: decoder)
    }
}
