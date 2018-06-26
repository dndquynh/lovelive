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
    var button : [SKSpriteNode] = []
    var scoreLabel : SKLabelNode!
    var score = 0
    var musicNote : SKSpriteNode!
    var playnote: QDSpriteNodeButton!
    var audioplayer : AVAudioPlayer!
    var pausebutton : QDSpriteNodeButton!
    var noteLabel: SKLabelNode!
    
    
    
    override func didMove(to view: SKView) {
    
        // Set up buttons
        for child in self.children {
            if child.name == "button" {
                if let child = child as? SKSpriteNode{
                    button.append(child)
                }
            }
        }
        
        // Set up pause button
        pausebutton = QDSpriteNodeButton(imageNamed: "pausebutton")
        pausebutton.name = "pause"
        pausebutton.position = CGPoint(x: 550, y: 420)
        pausebutton.size = CGSize(width: 100, height: 100)
        self.addChild(pausebutton)
        pausebutton.isUserInteractionEnabled = true
        pausebutton.delegate = self
        
        
        // Set up score label
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        
        // Set up music note
        musicNote = childNode(withName: "musicNoteNode") as! SKSpriteNode
        let scaleUp = SKAction.scale(to: 1, duration: 0.75)
        let scaleDown = SKAction.scale(to: 0.7, duration: 0.75)
        let pulse = SKAction.sequence([scaleDown, scaleUp])
        let pulseForever = SKAction.repeatForever(pulse)
        musicNote.run(pulseForever)
        
        // Set up note label
        noteLabel = childNode(withName: "noteLabel") as! SKLabelNode
        
        // Play song
        playAudioFile()
        
        //Set up play note
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlayNote), SKAction.wait(forDuration: 1)])))
        
        
    }
    
    func addPlayNote(){
        playnote = QDSpriteNodeButton(imageNamed: "circlebutton")
        playnote.name = "playnote"
        playnote.position = CGPoint(x : 0, y : 175)
        playnote.size = CGSize(width: 200, height: 200)
        self.addChild(playnote)
        playnote.isUserInteractionEnabled = true
        playnote.delegate = self
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
    
    
    // Calculate the min distance between two nodes
    func mindistance(first: CGPoint) -> Float{
        var d : [Float] = []
        for i in 0..<9{
            let dx = Float(button[i].position.x - first.x)
            let dy = Float(button[i].position.y - first.y)
            d.append(sqrt(dx * dx + dy * dy))
        }
        return d.min()!
    }
    
    func addToScore(distance:Float){
        if distance >= 141{
            noteLabel.text = "Bad"
            score += 100
        } else if distance >= 70 && distance < 141 {
            noteLabel.text = "Good"
            score += 200
        } else if distance >= 30 && distance < 70{
            noteLabel.text = "Great"
            score += 300
        } else if distance >= 0 && distance < 30 {
            noteLabel.text = "Perfect"
            score += 400
        }
        noteLabel.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.5),SKAction.fadeOut(withDuration: 0.5)]))

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
        if button.name == "playnote"{
            let d = mindistance(first: button.position)
            print("\(d)")
            if d < 200 {
                let touched = SKAction.removeFromParent()
                button.run(touched)
                addToScore(distance: d)
            }
        }
        else if button.name == "pause" {
            if !self.isPaused {
                self.isPaused = true
                audioplayer.pause()
                physicsWorld.speed = 0
            } else {
                self.isPaused = false
                audioplayer.play()
                physicsWorld.speed = 1
            }
        }
    }
}
