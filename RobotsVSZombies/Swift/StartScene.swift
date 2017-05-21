//
//  StartScene.swift
//  RobotsVSZombies
//
//  Created by Tong Zhang on 5/16/17.
//  Copyright © 2017 Tong Zhang. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

var topScore:Int = 0
var lastScore:Int = 0
var songTime:Double = 0

class StartScene: SKScene {
    var lastScoreLabel: SKLabelNode?
    var topScoreLabel: SKLabelNode?
    var cloudLeftNode = SKSpriteNode()
    var cloudRightNode = SKSpriteNode()
    
    var audioPlayer = AVAudioPlayer()
    var selectSound = AVAudioPlayer()
    
    override func sceneDidLoad() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:  Bundle.main.path(forResource: "menu_music", ofType: "wav")!))
            audioPlayer.prepareToPlay()
            
            selectSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:  Bundle.main.path(forResource: "select_sound", ofType: "wav")!))
            selectSound.prepareToPlay()
        } catch {
            print(error)
        }
    }
    
    override func didMove(to view: SKView) {
        // Score labels
        lastScoreLabel = (self.childNode(withName: "lastScoreLabel") as? SKLabelNode)!
        lastScoreLabel?.text = "Last Score: " + "\(lastScore)"
        topScoreLabel = (self.childNode(withName: "topScoreLabel") as? SKLabelNode)!
        topScoreLabel?.text = "Top Score: " + "\(topScore)"
        
        // Animating clouds
        cloudLeftNode = (self.childNode(withName: "cloudLeft") as? SKSpriteNode)!
        let cLRightEnd = CGPoint(x: 325+cloudLeftNode.size.width, y: cloudLeftNode.position.y)
        let clLeftEnd = CGPoint(x: -325 - cloudLeftNode.size.width, y: cloudLeftNode.position.y)

        let cLMoveR = SKAction.move(to: cLRightEnd, duration: 20)
        let cLDisappear = SKAction.fadeOut(withDuration: 0.1)
        let cLMoveBack = SKAction.move(to: clLeftEnd, duration: 3)
        let cLAppear = SKAction.fadeIn(withDuration: 0.1)
        
        let cLSequence = SKAction.sequence([cLMoveR, cLDisappear, cLMoveBack, cLAppear])
        let cLMoveForever = SKAction.repeatForever(cLSequence)
        
        cloudLeftNode.run(cLMoveForever)
        
        cloudRightNode = (self.childNode(withName: "cloudRight") as? SKSpriteNode)!
        let cRRightEnd = CGPoint(x: 325+cloudRightNode.size.width, y: cloudRightNode.position.y)
        let cRLeftEnd = CGPoint(x: -325 - cloudRightNode.size.width, y: cloudRightNode.position.y)
        
        let cRMoveL = SKAction.move(to: cRLeftEnd, duration: 19)
        let cRDisappear = SKAction.fadeOut(withDuration: 0.1)
        let cRMoveBack = SKAction.move(to: cRRightEnd, duration: 3)
        let cRAppear = SKAction.fadeIn(withDuration: 0.1)
        
        let cRSequence = SKAction.sequence([cRMoveL, cRDisappear, cRMoveBack, cRAppear])
        let cRMoveForever = SKAction.repeatForever(cRSequence)
        
        cloudRightNode.run(cRMoveForever)
        
        // Playing audio
        audioPlayer.play()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if atPoint(location).name == "startButton" {
                selectSound.play()
                
                if audioPlayer.isPlaying {
                    audioPlayer.stop()
                    audioPlayer.currentTime = 0
                }
                
                
                callGameScene()
            }
            
            if atPoint(location).name == "creditLabel" {
                selectSound.play()
                
                if audioPlayer.isPlaying {
                    audioPlayer.stop()
                    audioPlayer.currentTime = 0
                }
                
                callCreditScene()
            }
        }
    }
    
    func callGameScene() {
        if let scene = GameScene(fileNamed: "GameScene") {
            // Set the scale mode to scale to fit the window
            let myTransition = SKTransition.fade(withDuration: 0.8)
            scene.scaleMode = .aspectFill
            
            view?.presentScene(scene, transition: myTransition)
        }
    }
    
    func callCreditScene() {
        if let scene = GameScene(fileNamed: "CreditScene") {
            // Set the scale mode to scale to fit the window
            let myTransition = SKTransition.fade(withDuration: 0.8)
            scene.scaleMode = .aspectFill
            
            view?.presentScene(scene, transition: myTransition)
        }
    }

}
