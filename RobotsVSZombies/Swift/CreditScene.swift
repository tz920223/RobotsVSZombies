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

class CreditScene: SKScene {
    var audioPlayer = AVAudioPlayer()
    var selectSound = AVAudioPlayer()
    
    override func sceneDidLoad() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:  Bundle.main.path(forResource: "credit_music", ofType: "wav")!))
            audioPlayer.prepareToPlay()
            
            selectSound = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:  Bundle.main.path(forResource: "select_sound", ofType: "wav")!))
            selectSound.prepareToPlay()
        } catch {
            print(error)
        }
    }
    
    override func didMove(to view: SKView) {
        audioPlayer.play()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if atPoint(location).name == "backButton" {
                selectSound.play()
                
                if audioPlayer.isPlaying {
                    audioPlayer.stop()
                    audioPlayer.currentTime = 0
                }
                
                callStartScene()
            }
        }
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
