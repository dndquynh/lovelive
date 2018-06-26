//
//  MainMenuScene.swift
//  LoveLive
//
//  Created by Đỗ Quỳnh on 6/26/18.
//  Copyright © 2018 Đỗ Quỳnh. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene, QDSpriteNodeButtonDelegate {
    // UI Connections
    var buttonPlay: QDSpriteNodeButton!
    
    override func didMove(to view: SKView) {
        // Set up the scene
        
        // Set up UI connections
        buttonPlay = self.childNode(withName: "buttonPlay") as! QDSpriteNodeButton
        buttonPlay.isUserInteractionEnabled = true
        buttonPlay.delegate = self
    }
    
    func spriteNodeButtonPressed(_ button: QDSpriteNodeButton) {
        if let view = self.view {
            
            // Load SKScene from 'Gamescene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                
                // Set scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            // Debug helpers
            view.showsFPS = true
            view.showsPhysics = true
            view.showsDrawCount = true
        }
    }
    
    
}
