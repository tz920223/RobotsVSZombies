//
//  WinScene.swift
//  RobotsVSZombies
//
//  Created by Tong Zhang on 5/16/17.
//  Copyright © 2017 Tong Zhang. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class WinScene: SKScene {
    var lastScoreLabel: SKLabelNode?
    var topScoreLabel: SKLabelNode?
    var audioPlayer = AVAudioPlayer()
    var selectSound = AVAudioPlayer()
    
    var confetti = SKSpriteNode()

    override func sceneDidLoad() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:  Bundle.main.path(forResource: "game_win", ofType: "wav")!))
            audioPlayer.prepareToPlay()
            
            selectSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:  Bundle.main.path(forResource: "select_sound", ofType: "wav")!))
            selectSound.prepareToPlay()
        } catch {
            print(error)
        }
    }
    
    override func didMove(to view: SKView) {
        // Animate confetti
        confetti = (self.childNode(withName: "confetti") as? SKSpriteNode)!
        let confettiBottom = CGPoint(x: 0, y: -1334)
        let confettiTop = CGPoint(x: 0, y: 1334)
        
        let cMoveBottom = SKAction.move(to: confettiBottom, duration: 20)
        let cDisappear = SKAction.fadeOut(withDuration: 0.1)
        let cMoveUp = SKAction.move(to: confettiTop, duration: 0.1)
        let cAppear = SKAction.fadeIn(withDuration: 0.1)
        
        let cSequence = SKAction.sequence([cMoveBottom, cDisappear, cMoveUp, cAppear])
        let cMoveForever = SKAction.repeatForever(cSequence)
        
        confetti.run(cMoveForever)

        lastScoreLabel = (self.childNode(withName: "lastScoreLabel") as? SKLabelNode)!
        lastScoreLabel?.text = "Last Score: " + "\(lastScore)"
        topScoreLabel = (self.childNode(withName: "topScoreLabel") as? SKLabelNode)!
        topScoreLabel?.text = "Top Score: " + "\(topScore)"
        
        audioPlayer.play()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        callStartScene()
    }
    
    func callStartScene() {
        selectSound.play()
        
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
        }
        
        if let scene = GameScene(fileNamed: "StartScene") {
            // Set the scale mode to scale to fit the window
            let myTransition = SKTransition.fade(withDuration: 0.8)
            scene.scaleMode = .aspectFill
            
            view?.presentScene(scene, transition: myTransition)
        }
    }
}
