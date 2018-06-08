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

class GameScene: SKScene, QDSpriteNodeButtonDelegate {
    var button : [QDSpriteNodeButton] = []
    var scoreLabel : SKLabelNode!
    var score = 0
    var musicNote : SKSpriteNode!
    var playnote: SKSpriteNode!
    
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
        
        //Set up play note
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlayNote),SKAction.wait(forDuration: 1.0)])))
    }
    
    func addPlayNote(){
        playnote = SKSpriteNode(imageNamed: "circlebutton")
        playnote.position = CGPoint(x : 0, y : 175)
        playnote.size = CGSize(width: 150, height: 150)
        self.addChild(playnote)
        var i = arc4random_uniform(9)
        let moveToButton = SKAction.move(to: button[Int(i)].position, duration: 3)
        let moveDone = SKAction.removeFromParent()
        playnote.run(SKAction.sequence([moveToButton,moveDone]))
        
        
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
