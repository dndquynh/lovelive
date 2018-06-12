//
//  GameScene.swift
//  LoveLive
//
//  Created by Đỗ Quỳnh on 6/4/18.
//  Copyright © 2018 Đỗ Quỳnh. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation
import AVFoundation

class GameScene: SKScene, QDSpriteNodeButtonDelegate {
    var button : [QDSpriteNodeButton] = []
    var scoreLabel : SKLabelNode!
    var score = 0
    var musicNote : SKSpriteNode!
    var playnote: SKSpriteNode!
    var audioplayer : AVAudioPlayer!
    
    override func didMove(to view: SKView) {
        // Set up buttons
        for child in self.children {
            if child.name == "button" {
                if let child = child as? SKSpriteNode{
                    button.append(child as! QDSpriteNodeButton)
                }
            }
        }
        
        for button in button{
            button.isUserInteractionEnabled = true
            button.delegate = self
        }
        
        // Set up score label
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        
        // Set up music note
        musicNote = childNode(withName: "musicNoteNode") as! SKSpriteNode
        let scaleUp = SKAction.scale(to: 1, duration: 0.75)
        let scaleDown = SKAction.scale(to: 0.7, duration: 0.75)
        let pulse = SKAction.sequence([scaleDown, scaleUp])
        let pulseForever = SKAction.repeatForever(pulse)
        musicNote.run(pulseForever)
        
        // Play song
        playAudioFile()
        
        //Set up play note
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlayNote),SKAction.wait(forDuration: 1.0)])))
    }
    
    func addPlayNote(){
        playnote = SKSpriteNode(imageNamed: "circlebutton")
        playnote.position = CGPoint(x : 0, y : 175)
        playnote.size = CGSize(width: 150, height: 150)
        self.addChild(playnote)
        let i = arc4random_uniform(9)
        let pos = button[Int(i)].position
        let initpos = playnote.position
        var finalpos = CGPoint(x: 0, y: 0)
        let direction = CGPoint(x: initpos.x - pos.x, y: initpos.y - pos.y)
        if abs(pos.x) <= abs(pos.y) {
            if pos.y < 0 {
                finalpos = CGPoint(x: initpos.x - (direction.x * (initpos.y + 540) / direction.y), y: -540)
            } else{
                finalpos = CGPoint(x: initpos.x - (direction.x * (initpos.y - 540) / direction.y), y: 540)
            }
        } else{
            if pos.x < 0{
                finalpos = CGPoint(x: -960, y: initpos.y - (direction.y * (initpos.x + 960) / direction.x))
            } else{
                finalpos = CGPoint(x: 960, y: initpos.y - (direction.y * (initpos.x - 960) / direction.x))
            }
        }
        let moveToButton = SKAction.move(to:finalpos, duration: 3)
        let moveDone = SKAction.removeFromParent()
        playnote.run(SKAction.sequence([moveToButton,moveDone]))
    }
    
    func playAudioFile() {
        guard let url = Bundle.main.url(forResource: "TheTruthUntold", withExtension: "mp3") else {return}
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioplayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let aPlayer  = audioplayer else {return}
            aPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func addToScore(){
        score += 302
        scoreLabel.text = "\(score)"
    }
    
    func endGame(){
        scoreLabel.text = "Liveshow completed"
        score = 0
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    // MARK: - QDSpriteNodeButtonDelegate
    func spriteNodeButtonPressed(_ button: QDSpriteNodeButton) {
        print("We are in the scene")
        addToScore()
    }
}
