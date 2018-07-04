//
//  MainMenuScene.swift
//  LoveLive
//
//  Created by Đỗ Quỳnh on 6/26/18.
//  Copyright © 2018 Đỗ Quỳnh. All rights reserved.
//

import SpriteKit
import FacebookLogin
import FacebookCore

class MainMenuScene: SKScene, LoginButtonDelegate, QDSpriteNodeButtonDelegate {
    
    // UI Connections
    let loginButton = LoginButton(readPermissions: [.publicProfile])
    var playbutton : QDSpriteNodeButton!
    
    override func didMove(to view: SKView) {
        // Set up the scene
        
        // Set up Login FB button
        self.view?.addSubview(loginButton)
        loginButton.frame = CGRect(x: (self.view?.center.x)!-150, y: (self.view?.center.y)! + 25, width: 300, height: 50)
        loginButton.delegate = self
        
        // Set up play button
        playbutton = childNode(withName: "playgamebutton") as! QDSpriteNodeButton
        playbutton.isUserInteractionEnabled = true
        playbutton.delegate = self as QDSpriteNodeButtonDelegate
        
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("Did log out of facebook.")
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        loginButton.isHidden = true
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
    
    func spriteNodeButtonPressed(_ button: QDSpriteNodeButton) {
        loginButton.isHidden = true
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
