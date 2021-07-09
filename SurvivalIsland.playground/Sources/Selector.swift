import SpriteKit
import Foundation

extension NSEvent {
    func isWithin(_ node: CommandSprite) -> Bool {
        // turns out this just gives window coord space
        // i don't want to bother converting anything so I will leave it like this
        let offsetFromCenter = location(in: node)
        
        let x = offsetFromCenter.x - node.rect.origin.x
        let y = offsetFromCenter.y - node.rect.origin.y
        
        return x > 0 && x < node.rect.size.width && y > 0 && y < node.rect.size.height
    }
}

public class Selector: SKShapeNode {
    var move: CommandSprite!
    var jump: CommandSprite!
    var attack: CommandSprite!
    var check: CommandSprite!
    
    public var playerSees: SKLabelNode!
    
    public var checkMode: Target?
    public var callback: ((Command) -> Void)?
    
    init(withRect rect: CGRect) {
        super.init()
        
        path = CGPath(rect: rect, transform: nil)
        fillColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        lineWidth = 0
        zPosition = 1.5
        
        let newCommandText = SKSpriteNode(texture: SKTexture(imageNamed: "newcommandtext"))
        newCommandText.position.x = 0
        newCommandText.position.y = rect.height / 2 - 60
        newCommandText.size = CGSize(width: 296, height: 40)
        addChild(newCommandText)
        
        playerSees = SKLabelNode()
        playerSees.position = CGPoint(x: 0, y: rect.height / 2 - 160)
        playerSees.isHidden = true
        addChild(playerSees)
        
        let size = CGSize(width: 160, height: 40)
        let leftColumn = CGFloat(-200)
        let rightColumn = CGFloat(200 - 160)
        let topRow = CGFloat(80.0)
        let bottomRow = CGFloat(-80.0)
        
        move = CommandSprite(.move, withRect:
            CGRect(origin: CGPoint(x: leftColumn, y: topRow), size: size))
        jump = CommandSprite(.jump, withRect:
            CGRect(origin: CGPoint(x: rightColumn, y: topRow), size: size))
        attack = CommandSprite(.attack, withRect:
            CGRect(origin: CGPoint(x: leftColumn, y: bottomRow), size: size))
        check = CommandSprite(.check(.invalid), withRect:
            CGRect(origin: CGPoint(x: rightColumn, y: bottomRow), size: size))
        
        addChild(move)
        addChild(jump)
        addChild(attack)
        addChild(check)
    }
    
    public override func mouseDown(with event: NSEvent) {
        var clickedCommand = Command.invalid
        
        if event.isWithin(move) {
            clickedCommand = .move
        }
        
        if event.isWithin(jump) {
            clickedCommand = .jump
        }
        
        if event.isWithin(attack) {
            clickedCommand = .attack
        }
        
        if event.isWithin(check) {
            clickedCommand = .check(.invalid)
        }
        
        // gave up on == an enum XD
        switch clickedCommand {
        case .invalid:
            break
        default:
            if let c = callback {
                c(clickedCommand)
                checkMode = nil
                playerSees.isHidden = true
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
}
