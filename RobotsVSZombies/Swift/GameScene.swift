//
//  GameScene.swift
//  RobotsVSZombies
//
//  Created by Tong Zhang on 5/15/17.
//  Copyright © 2017 Tong Zhang. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation


class GameScene: SKScene, SKPhysicsContactDelegate {
    var currentScore = 0
    var timer = Timer()
    var currentTime = 45
    var currentBattery = 3
    var levelNumber = 0
    
    var audioPlayer = AVAudioPlayer()
    
    var scoreLabel: SKLabelNode?
    var timeLabel: SKLabelNode?
    var player:SKSpriteNode?
    var battery:SKSpriteNode?
    
    let heartSound = SKAction.playSoundFileNamed("heart_shoot.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosion_effect.wav", waitForCompletion: false)
    let lifeSound = SKAction.playSoundFileNamed("lose_life.wav", waitForCompletion: false)
    
    // Physics bodies
    struct PhysicsCategories {
        static let None:UInt32 = 0
        static let Player:UInt32 = 0b1 // 1
        static let Heart:UInt32 = 0b10 // 2
        static let Enemy:UInt32 = 0b100 // 4
    }
    
    override func sceneDidLoad() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:  Bundle.main.path(forResource: "battle_music", ofType: "wav")!))
            audioPlayer.prepareToPlay()
        } catch {
            print(error)
        }
    }
    
    override func didMove(to view: SKView) {
        currentScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = self.childNode(withName: "scoreLabel") as? SKLabelNode
        scoreLabel?.text = String(currentScore)
        timeLabel = self.childNode(withName: "timeLabel") as? SKLabelNode
        timeLabel?.text = String(currentTime)
        
        player = self.childNode(withName: "player") as? SKSpriteNode
        player?.physicsBody = SKPhysicsBody(rectangleOf: (player?.size)!)
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody?.categoryBitMask = PhysicsCategories.Player
        
        // Collision & Contacts rules
        player?.physicsBody?.collisionBitMask = PhysicsCategories.None
        player?.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        
        battery = self.childNode(withName: "battery") as? SKSpriteNode
        
        startNewLevel()
        changeLives()
        
        startTimer()
        audioPlayer.play()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
            // if player has hit enemy
            
            if body1.node != nil && body2.node != nil{
                spawnExplosion(spawnPosition: (body1.node?.position)!)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            callGameOver()
        }
        
        if body1.categoryBitMask == PhysicsCategories.Heart && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < (self.size.height * 0.15) {
            // if bullet has hit enemy that is on screen
            
            addScore()
            
            if body2.node != nil {
                spawnExplosion(spawnPosition: (body2.node?.position)!)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
//        fireHeart()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
        fireHeart()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            player?.position.x += amountDragged
            
            if (player?.position.x)! > 325 {
                player?.position.x = 325
            }
            
            if (player?.position.x)! < -325  {
                player?.position.x = -325
            }
        }
        
    }
    
    // Timer functions
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    func updateCounter() {
        if currentTime > 0 {
            print("\(currentTime)")
            currentTime -= 1
            timeLabel?.text = String(currentTime)
            
        }
        
        checkWin()
    }
    
    func checkWin() {
        if currentTime == 0 && currentBattery > 0 {
            callGameWin()
        }
    }
    
    // Shooting function
    func fireHeart() {
        let heart = SKSpriteNode(imageNamed: "shoot")
        heart.size.width = 62.8
        heart.size.height = 53.74
        heart.position = (player?.position)!
        heart.zPosition = 2
        heart.physicsBody = SKPhysicsBody(rectangleOf: (heart.size))
        heart.physicsBody?.affectedByGravity = false
        heart.physicsBody?.categoryBitMask = PhysicsCategories.Heart
        
        // Collision & Contacts rules
        heart.physicsBody?.collisionBitMask = PhysicsCategories.None
        heart.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        
        self.addChild(heart)
        
        let moveHeart = SKAction.moveTo(y: self.size.height + heart.size.height, duration: 1.5)
        let deleteHeart = SKAction.removeFromParent()
        
        let heartSequence = SKAction.sequence([heartSound, moveHeart,deleteHeart])
        heart.run(heartSequence)
    }
    
    // Spawning enemy functions
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xffffffff)
    }
    
    func random(min:CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func spawnEnemy() {
        let randomXStart = random(min: -325, max: 325)
        let randomXEnd = random(min: -325, max: 325)
        
        let startPoint = CGPoint(x: randomXStart, y:self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y:-self.size.height * 0.5)
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.size.height = 104.182
        enemy.size.width = 182.444
        enemy.zPosition = 1
        enemy.position = startPoint
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: (enemy.size))
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = PhysicsCategories.Enemy
        
        // Collision & Contact rules
        enemy.physicsBody?.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Heart
        
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 4)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseLife)
        let enemySequence = SKAction.sequence([moveEnemy,deleteEnemy, loseALifeAction])
        enemy.run(enemySequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        
        enemy.zRotation = amountToRotate

    }
    
    // Scoring + Leveling
    func addScore() {
        currentScore += 1
        scoreLabel?.text = String(currentScore)
        
        if currentScore == 10 || currentScore == 20 || currentScore == 40 {
            startNewLevel()
        }
    }
    
    func startNewLevel() {
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1
        case 2: levelDuration = 0.8
        case 3: levelDuration = 0.7
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.3
            print("Cannot find level info")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        
        self.run(spawnForever, withKey: "spawningEnemies")
        
    }
    
    func spawnExplosion(spawnPosition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 5
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    
    // Changing Battery Functions
    func loseLife() {
        currentBattery -= 1
        changeLives()
        
        print(currentBattery)
        
        battery?.run(lifeSound)
        
        if currentBattery == 0 {
            callGameOver()
        }
    }
    
    func changeLives() {
        if currentBattery == 2 {
            battery?.texture = SKTexture(imageNamed: "2Battery")
        } else if currentBattery == 1 {
            battery?.texture = SKTexture(imageNamed: "1Battery")
        } else if currentBattery <= 0 {
            battery?.texture = SKTexture(imageNamed: "0Battery")
        }
    }
    
    // Switch Screens Functions
    func callGameOver() {
        timer.invalidate()
        
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
        }
        
        lastScore = currentScore
        
        if lastScore >= topScore {
            topScore = lastScore
            lastScore = currentScore
        }
        
        if let scene = GameScene(fileNamed: "LoseScene") {
            let myTransition = SKTransition.fade(withDuration: 0.5)
            scene.scaleMode = .aspectFill

            view?.presentScene(scene, transition: myTransition)
        }
    }
    
    func callGameWin() {
        timer.invalidate()
        
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
        }
        lastScore = currentScore
        
        if lastScore >= topScore {
            topScore = lastScore
        }
        
        if let scene = GameScene(fileNamed: "WinScene") {
            // Set the scale mode to scale to fit the window
            let myTransition = SKTransition.fade(withDuration: 0.8)
            scene.scaleMode = .aspectFill
            
            view?.presentScene(scene, transition: myTransition)
        }
    }

}
