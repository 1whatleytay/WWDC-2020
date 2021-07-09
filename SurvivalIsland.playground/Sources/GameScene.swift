import Foundation
import AVFoundation
import SpriteKit

extension NSEvent {
    func isWithin(_ node: SKSpriteNode) -> Bool {
        let offsetFromCenter = location(in: node)
        let x = offsetFromCenter.x + node.size.width / 2
        let y = offsetFromCenter.y + node.size.height / 2
        
        return x > 0 && x < node.size.width && y > 0 && y < node.size.height
    }
}

public class GameScene: SKScene {
    var player: SKSpriteNode!
    var flag: SKSpriteNode!
    
    var loopEditor: SKSpriteNode!
    var add: SKSpriteNode!
    
    var play: SKSpriteNode!
    var trash: SKSpriteNode!
    
    var level = 0
    
    var arrow: SKSpriteNode!
    
    var won = false
    
    var selector: Selector!
    var checkSelector: CheckSelector!
    
    var playerInitialPosition: CGPoint!
    
    var commandSprites = [CommandSprite]()
    
    var isPlaying = false
    var executeIndex = 0
    var lastCommandTime: TimeInterval!
    
    var gameMusic: AVAudioPlayer!
    
    let commandPadding = CGFloat(10.0)
    
    func getActions() -> [String:SKAction] {
        // not comfortable with swift optionals yet
        let node = SKNode(fileNamed: "Actions")!
        let actions = node.value(forKey: "actions") as? [String:SKAction]
        
        return actions!
    }
    
    func addCommand(_ command: Command) {
        // can't modify commands while the player is executing
        if isPlaying {
            return
        }
        
        // can't make any more beyond 10, not dealing with gui limits right now
        if commandSprites.count > 10 {
            // error text
            return
        }
        
        let newOrigin = CGPoint(
            x: add.position.x - add.size.width / 2,
            y: add.position.y - (add.size.height + commandPadding) * CGFloat(commandSprites.count + 1) - 20
        )
        
        let sprite = CommandSprite(command, withRect: CGRect(origin: newOrigin, size: add.size))
        loopEditor.addChild(sprite)
        commandSprites.append(sprite)
    }
    
    func removeAllCommands() {
        // can't modify commands while the player is executing
        if isPlaying {
            return
        }
        
        loopEditor.removeChildren(in: commandSprites)
        commandSprites.removeAll()
    }
    
    func executeCommand() {
        player.removeAllActions()
        
        // execute this command
        switch commandSprites[executeIndex].command {
        case .move:
            run(getActions()["patsound"]!)
            player.run(getActions()["baseguywalk"]!)
            player.physicsBody?.applyImpulse(CGVector(dx: 50, dy:0))
        case .jump:
            run(getActions()["jumpsound"]!)
            player.physicsBody?.applyImpulse(CGVector(dx: 30, dy: 160))
        case .check(let target):
            
            var matches = false
            switch target {
            case .wall:
                let playerSeeCone = CGRect(origin: player.position, size: CGSize(width: 160, height: 40))
            
                enumerateChildNodes(withName: "wall") {
                    (node, stop) in
                    
                    let wallNode = (node as? SKSpriteNode)!
                    if CGRect(origin: wallNode.position, size: wallNode.size).intersects(playerSeeCone) {
                        matches = true
                    }
                }
            case .enemy:
                let playerSeeCone = CGRect(origin: player.position, size: CGSize(width: 120, height: 40))
                
                enumerateChildNodes(withName: "enemy") {
                    (node, stop) in
                    
                    let enemyNode = (node as? SKSpriteNode)!
                    if CGRect(origin: enemyNode.position, size: enemyNode.size).intersects(playerSeeCone) {
                        matches = true
                    }
                }
            default:
                break
            }
            
            if !matches {
                executeIndex += 1
            }
        default:
            break
        }
    }
    
    func nextCommand() {
        // have it loop instead of overflow
        executeIndex = (executeIndex + 1) % commandSprites.count
        
        setArrowIndex(index: executeIndex)
        executeCommand()
    }
    
    func setArrowIndex(index: Int) {
        let newOrigin = CGPoint(
            x: add.position.x - add.size.width / 2 - 40,
            y: add.position.y - (add.size.height + commandPadding) * (CGFloat(index) + 1.10)
        )
        
        arrow.position = newOrigin
    }
    
    func startPlaying() {
        // cannot run an empty program
        if (commandSprites.isEmpty) {
            // error text
            return
        }
        
        // restart program yep
        // set player position to start of level ok
        // reset enemy positions
        // really just reload level
        executeIndex = 0
        player.isHidden = false
        player.position = playerInitialPosition
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        lastCommandTime = nil
        
        isPlaying = true
        
        physicsWorld.speed = 1.0
        arrow.isHidden = false
        setArrowIndex(index: executeIndex)
        executeCommand()
        
        play.texture = SKTexture(imageNamed: "stop")
    }
    
    func stopPlaying() {
        isPlaying = false
        
        physicsWorld.speed = 0.0
        player.removeAllActions()
        arrow.isHidden = true
        
        play.texture = SKTexture(imageNamed: "play")
    }
    
    public override func sceneDidLoad() {
        player = childNode(withName: "player") as? SKSpriteNode
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0.0 // no bouncing
        playerInitialPosition = player.position
        
        enumerateChildNodes(withName: "ground") {
            (node, stop) in
            let ground = (node as? SKSpriteNode)!
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.isDynamic = false
        }
        
        
        enumerateChildNodes(withName: "wall") {
            (node, stop) in
            let wallNode = node as! SKSpriteNode
            // for some reason, physics bodies are too long
            // i presume i am misunderstanding something
            node.physicsBody = SKPhysicsBody(rectangleOf:
                CGSize(width: wallNode.size.width / 2, height: wallNode.size.height))
            node.physicsBody?.isDynamic = false
        }
        
        enumerateChildNodes(withName: "enemy") {
            (node, stop) in
            let enemyNode = node as! SKSpriteNode
            enemyNode.run(self.getActions()["enemyidle"]!)
        }
        
        flag = childNode(withName: "flag") as? SKSpriteNode
        flag.run(getActions()["flagfwoosh"]!)
        
        loopEditor = childNode(withName: "loopEditor") as? SKSpriteNode
        add = loopEditor.childNode(withName: "add") as? SKSpriteNode
        play = loopEditor.childNode(withName: "play") as? SKSpriteNode
        trash = loopEditor.childNode(withName: "trash") as? SKSpriteNode
        
        arrow = SKSpriteNode(imageNamed: "arrow")
        arrow.size = CGSize(width: 32, height: 32)
        arrow.isHidden = true
        loopEditor.addChild(arrow)
        
        let screenRect =
            CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size)
        
        selector = Selector(withRect: screenRect)
        // vue.js strikes back @select=""
        selector.callback = {
            (command: Command) in

            self.selector.isHidden = true
            
            switch command {
            case .check(_):
                self.checkSelector.isHidden = false
            default:
                self.addCommand(command)
            }
        }
        selector.isHidden = true
        addChild(selector)
        
        checkSelector = CheckSelector(withRect: screenRect)
        checkSelector.callback = {
            (target: Target) in
            self.addCommand(Command.check(target))
            self.checkSelector.isHidden = true
            
            self.selector.checkMode = target
            // could just make this a method call but can't be bothered with time
            self.selector.playerSees.text = "When Player Sees \(getName(for: target))..."
            self.selector.playerSees.isHidden = false
            self.selector.isHidden = false
        }
        checkSelector.isHidden = true
        addChild(checkSelector)
        
        let temp = Bundle.main.path(forResource: "gametune", ofType: "mp3")
        gameMusic = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: temp!))
        gameMusic.play()
    }
    
    public override func mouseDown(with event: NSEvent) {
        // events seem to need to be manually passed down
        if !selector.isHidden {
            selector.mouseDown(with: event)
        } else if !checkSelector.isHidden {
            checkSelector.mouseDown(with: event)
        } else {
            if event.isWithin(add) {
                selector.isHidden = false
            }
            
            if event.isWithin(trash) {
                removeAllCommands()
            }
            
            if event.isWithin(play) {
                if isPlaying {
                    stopPlaying()
                } else {
                    startPlaying()
                }
            }
        }
    }
    
    public override func update(_ currentTime: TimeInterval) {
        if isPlaying {
            let timeUntilNextCommand = 1.0 // 1 instruction per second
            
            if lastCommandTime == nil {
                lastCommandTime = currentTime
            }

            while lastCommandTime + timeUntilNextCommand < currentTime {
                nextCommand()

                lastCommandTime += timeUntilNextCommand
            }
            
            // win level!
            if !won && player.frame.intersects(flag.frame) {
                won = true
                
                stopPlaying()
                
                gameMusic.pause()
                
                var winsong = "win"
                if level == 2 {
                    winsong = "victorysong"
                }
                
                run(getActions()[winsong]!, completion: {
                    print("next")
                    
                    var next = "GameScene"
                    switch self.level {
                    case 0:
                        next = "Level2"
                    case 1:
                        next = "Level3"
                    default:
                        break
                    }
                    
                    let newScene = GameScene(fileNamed: next)!
                    newScene.level = self.level + 1
                    newScene.scaleMode = .aspectFill
                    
                    self.scene!.view!.presentScene(newScene, transition: SKTransition.fade(withDuration: 1.0))
                })
            }
            
            enumerateChildNodes(withName: "enemy") {
                (node, stop) in
                if self.player.frame.intersects(node.frame) {
                    self.run(self.getActions()["death"]!)
                    
                    self.stopPlaying()
                    
                    self.player.isHidden = true
                }
            }
        }
    }
}
