//
//  LoseScene.swift
//  RobotsVSZombies
//
//  Created by Tong Zhang on 5/16/17.
//  Copyright © 2017 Tong Zhang. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class LoseScene: SKScene {
    var lastScoreLabel: SKLabelNode?
    var topScoreLabel: SKLabelNode?
    var fire = SKSpriteNode()
    
    var audioPlayer = AVAudioPlayer()
    var selectSound = AVAudioPlayer()
    
    override func sceneDidLoad() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:  Bundle.main.path(forResource: "lose_music", ofType: "wav")!))
            audioPlayer.prepareToPlay()
            
            selectSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:  Bundle.main.path(forResource: "select_sound", ofType: "wav")!))
            selectSound.prepareToPlay()
        } catch {
            print(error)
        }
    }

    
    override func didMove(to view: SKView) {
        // Animating fire
        fire = (self.childNode(withName: "fire") as? SKSpriteNode)!
        let fireBottom = CGPoint(x: 0, y: -1334)
        let fireTop = CGPoint(x: 0, y: 0)
        
        let fMoveBottom = SKAction.move(to: fireBottom, duration: 0)
        let fDisappear = SKAction.fadeOut(withDuration: 0.2)
        let fMoveUp = SKAction.move(to: fireTop, duration: 10)
        let fAppear = SKAction.fadeIn(withDuration: 0.2)
        
        let fSequence = SKAction.sequence([fMoveUp, fDisappear, fMoveBottom, fAppear])
        let fMoveForever = SKAction.repeatForever(fSequence)
        
        fire.run(fMoveForever)
        
        
        lastScoreLabel = (self.childNode(withName: "lastScoreLabel") as? SKLabelNode)!
        lastScoreLabel?.text = "Last Score: " + "\(lastScore)"
        topScoreLabel = (self.childNode(withName: "topScoreLabel") as? SKLabelNode)!
        topScoreLabel?.text = "Top Score: " + "\(topScore)"
        
        audioPlayer.play()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectSound.play()
        
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
        }
        
        callStartScene()
    }
    
    func callStartScene() {
        if let scene = GameScene(fileNamed: "StartScene") {
            // Set the scale mode to scale to fit the window
            let myTransition = SKTransition.fade(withDuration: 0.8)
            scene.scaleMode = .aspectFill
            
            view?.presentScene(scene, transition: myTransition)
        }
    }
}
