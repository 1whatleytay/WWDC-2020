import Foundation

import SpriteKit
import Foundation

public class CheckSelector: SKShapeNode {
    public var callback: ((Target) -> Void)?
    
    var playerSees: SKLabelNode!
    
    var wallIcon: SKSpriteNode!
    var enemyIcon: SKSpriteNode!
    var cliffIcon: SKSpriteNode!
    
    var wallLabel: SKLabelNode!
    var enemyLabel: SKLabelNode!
    var cliffLabel: SKLabelNode!
    
    init(withRect rect: CGRect) {
        super.init()
        
        path = CGPath(rect: rect, transform: nil)
        fillColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        lineWidth = 0
        zPosition = 1.5
        
        let newCommandText = SKSpriteNode(texture: SKTexture(imageNamed: "checkifcommandtext"))
        newCommandText.position.x = 0
        newCommandText.position.y = rect.height / 2 - 60
        newCommandText.size = CGSize(width: 192, height: 40)
        addChild(newCommandText)
        
        let size = CGSize(width: 128, height: 128)
        
        wallIcon = SKSpriteNode(texture: SKTexture(imageNamed: "wallicon"))
        wallIcon.size = size
        wallIcon.position = CGPoint(x: -200, y: 0)
        enemyIcon = SKSpriteNode(texture: SKTexture(imageNamed: "evilicon"))
        enemyIcon.size = size
        enemyIcon.position = CGPoint(x: 200, y: 0)
//        cliffIcon = SKSpriteNode(texture: SKTexture(imageNamed: "clifficon"))
//        cliffIcon.size = size
//        cliffIcon.position = CGPoint(x: 200, y: 0)
        
        // dont have time to make these clickable
        wallLabel = SKLabelNode(text: "Wall")
        wallLabel.position = CGPoint(x: wallIcon.position.x, y: wallIcon.position.y - 100)
        enemyLabel = SKLabelNode(text: "Enemy")
        enemyLabel.position = CGPoint(x: enemyIcon.position.x, y: enemyIcon.position.y - 100)
//        cliffLabel = SKLabelNode(text: "Cliff")
//        cliffLabel.position = CGPoint(x: cliffIcon.position.x, y: cliffIcon.position.y - 100)
        
        playerSees = SKLabelNode(text: "Player Sees...")
        playerSees.position = CGPoint(x: 0, y: rect.height / 2 - 140)
        addChild(playerSees)
        
        addChild(wallIcon)
        addChild(enemyIcon)
//        addChild(cliffIcon)
        
        addChild(wallLabel)
        addChild(enemyLabel)
//        addChild(cliffLabel)
    }
    
    public override func mouseDown(with event: NSEvent) {
        var clickedTarget = Target.invalid
        
        if event.isWithin(wallIcon) {
            clickedTarget = .wall
        }
        
        if event.isWithin(enemyIcon) {
            clickedTarget = .enemy
        }
        
        // gave up on == an enum XD
        switch clickedTarget {
        case .invalid:
            break
        default:
            if let c = callback {
                c(clickedTarget)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
}
