//
//  QDSpriteNodeButton.swift
//  LoveLive
//
//  Created by Đỗ Quỳnh on 6/6/18.
//  Copyright © 2018 Đỗ Quỳnh. All rights reserved.
//

import SpriteKit

protocol QDSpriteNodeButtonDelegate: class {
    func spriteNodeButtonPressed( _ button: QDSpriteNodeButton)
}

class QDSpriteNodeButton: SKSpriteNode {
    
    weak var delegate: QDSpriteNodeButtonDelegate?
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
        if contains(pos){
            delegate?.spriteNodeButtonPressed(self)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if parent != nil {
                 self.touchUp(atPoint: t.location(in: parent!))
            }
    }
}
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if parent != nil {
                self.touchUp(atPoint: t.location(in: parent!))
            }
        }
    }
}
