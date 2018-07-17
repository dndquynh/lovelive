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
import aubio

class GameScene: SKScene, QDSpriteNodeButtonDelegate {
    var button : [SKSpriteNode] = []
    var scoreLabel : SKLabelNode!
    var score = 0
    var musicNote : SKSpriteNode!
    var playnote: QDSpriteNodeButton!
    var audioplayer : AVAudioPlayer!
    var pausebutton : QDSpriteNodeButton!
    var noteLabel: SKLabelNode!
    var settingBoard : SKSpriteNode!
    var quitButton : QDSpriteNodeButton!
    var resumeButton: QDSpriteNodeButton!
    var background : SKSpriteNode!
    var messageBoard : SKSpriteNode!
    var isGamePaused: Bool = false
    var isSetup : Bool = false
    
    // Current position of the song in seconds
    var songPosition: Double!
    
    // Current position of the song in beats
    var songPosinBeat: Double!
    
    // Duration of a beat
    var secPerBeat: Double!
    
    // how much time has passed since the song started
    var dspTimeSong: Double!
    
    var audio: AVAudioPlayer!
    
    var bpm: Double = 111
    
    var notedata : [[Double]] = [[]]
    
    var nextIndex = 0
    
    override func didMove(to view: SKView) {
        
        // Set up observer
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
        // set up background
        background = childNode(withName: "background") as! SKSpriteNode
    
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
        
        secPerBeat = 60 / bpm
        
        //Set up play note
        //run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlayNote), SKAction.wait(forDuration: 1)])))
        
        // Beat file
        var data = readDataFromCSV(fileName: "beattrack", fileType: ".csv")
        data = cleanRows(file: data!)
        notedata = csv(data: data!)
    }
    
    
    @objc func applicationWillResignActive(_ application: UIApplication) {
        if !isGamePaused {
            self.isPaused = true
            isGamePaused = true
        }
    }
    
    @objc func applicationDidEnterBackground(_ application: UIApplication) {
        audioplayer.pause()
        do {
                try AVAudioSession.sharedInstance().setActive(false)
        } catch let error{
            print(error.localizedDescription)
        }
        self.view?.isPaused = true
    }
    
    @objc func applicationWillEnterForeground(_ application: UIApplication){
        self.view?.isPaused = false
        if isGamePaused{
            self.isPaused = true
            audioplayer.pause()
            if !isSetup {
                setup()
            }
        }
    }
    
    func addPlayNote(pos: CGPoint){
        playnote = QDSpriteNodeButton(imageNamed: "circlebutton")
        playnote.name = "playnote"
        playnote.position = CGPoint(x : 0, y : 175)
        playnote.size = CGSize(width: 200, height: 200)
        self.addChild(playnote)
        playnote.isUserInteractionEnabled = true
        playnote.delegate = self
        //let i = arc4random_uniform(9)
        //let pos = button[Int(i)].position
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
            dspTimeSong = audioplayer.currentTime
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
    
    func setup() {
        // Set up setting board
        settingBoard = SKSpriteNode(imageNamed: "settingboard")
        settingBoard.size = CGSize(width: 1300, height: 700)
        settingBoard.position = CGPoint(x: 0, y: -50)
        settingBoard.zPosition = 1
        let comment = SKLabelNode(fontNamed: "Pixel Digivolve")
        comment.fontSize = 70
        comment.fontColor = UIColor.black
        comment.text = "Game Paused"
        comment.position = CGPoint(x: 0, y: 150)
        comment.zPosition = 2
        settingBoard.addChild(comment)
        
        // Add quit button to the setting board
        quitButton = QDSpriteNodeButton(imageNamed: "quitbutton")
        quitButton.size = CGSize(width: 400, height: 200)
        quitButton.position = CGPoint(x: -200, y: -150)
        quitButton.zPosition = 2
        quitButton.name = "quit"
        quitButton.isUserInteractionEnabled = true
        quitButton.delegate = self
        settingBoard.addChild(quitButton)
        
        // Add resume button to the setting board
        resumeButton = QDSpriteNodeButton(imageNamed: "resumebutton")
        resumeButton.size = CGSize(width: 370, height: 170)
        resumeButton.position = CGPoint(x: 200, y: -150)
        resumeButton.zPosition = 2
        resumeButton.name = "resume"
        resumeButton.isUserInteractionEnabled = true
        resumeButton.delegate = self
        settingBoard.addChild(resumeButton)
        
        // Add setting board to the scene
        self.addChild(settingBoard)
        
    }
    
    // Read beat data from csv file
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";;", with: "")
        //        cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
        return cleanFile
    }
    
    func csv(data: String) -> [[Double]] {
        var result: [[Double]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows{
            let columns = row.components(separatedBy: ",")
            if let beatTime = Double(columns[0]) {
                if let notePos = Double(columns[1]) {
                    result.append([beatTime,notePos])
                }
            }
        }
            
            
            /*if let beatTime = Double(row){
                result.append(beatTime)
            }
            else {
                print("Not a valid number.")
            }*/
        
        return result
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        // Calculate the position in seconds
        songPosition = audioplayer.currentTime
        //print("\(songPosition)")
        // Calculate the position in beats
        songPosinBeat = songPosition / secPerBeat
        
        if nextIndex < notedata.count && notedata[nextIndex][0] - 3  < songPosition {
            print("\(notedata[nextIndex][0] ) || \(songPosition)")
            addPlayNote(pos : button[Int(notedata[nextIndex][1])].position)
            nextIndex += 1
        }
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
            if !self.isPaused{
                isGamePaused = true
                self.isPaused = true
                audioplayer.pause()
                physicsWorld.speed = 0
                background.zPosition = 1
                
                // Set up setting board
                setup()
                isSetup = true
            }
        }
        else if button.name == "resume" {
            isGamePaused = false
            isSetup = false
            settingBoard.run(SKAction.hide())
            self.isPaused = false
            background.zPosition = -1
            audioplayer.play()
            physicsWorld.speed = 0
        }
        else if button.name == "quit" {
            settingBoard.isHidden = true
            
            // Set up message board
            messageBoard = SKSpriteNode(imageNamed: "settingboard")
            messageBoard.size = CGSize(width: 1300, height: 700)
            messageBoard.position = CGPoint(x: 0, y: -50)
            messageBoard.zPosition = 1
            let message = SKLabelNode(fontNamed: "Pixel Digivolve")
            message.fontSize = 50
            message.fontColor = UIColor.black
            message.text = "Are you sure you want to quit?"
            message.position = CGPoint(x: 0, y: 50)
            message.zPosition = 2
            messageBoard.addChild(message)
            
            let title = SKLabelNode(fontNamed: "Pixel Digivolve")
            title.fontSize = 70
            title.fontColor = UIColor.black
            title.text = "Quit Game"
            title.position = CGPoint(x: 0, y: 150)
            title.zPosition = 2
            messageBoard.addChild(title)
            
            // Add yes and no button to message board
            let yesButton = QDSpriteNodeButton(imageNamed: "yesbutton")
            yesButton.size = CGSize(width: 390, height: 205)
            yesButton.position = CGPoint(x: -200, y: -150)
            yesButton.zPosition = 2
            yesButton.name = "yes"
            yesButton.isUserInteractionEnabled = true
            yesButton.delegate = self
            messageBoard.addChild(yesButton)
            
            let noButton = QDSpriteNodeButton(imageNamed: "nobutton")
            noButton.size = CGSize(width: 400, height: 200)
            noButton.position = CGPoint(x: 200, y: -150)
            noButton.zPosition = 2
            noButton.name = "no"
            noButton.isUserInteractionEnabled = true
            noButton.delegate = self
            messageBoard.addChild(noButton)
            
            // Add message board to the scene
            self.addChild(messageBoard)
        }
            // If yes, return to mainmenu scene
        else if button.name == "yes" {
            if let view = self.view {
                
                // Load SKScene from 'Gamescene.sks'
                if let scene = SKScene(fileNamed: "MainMenuScene") {
                    
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
        else if button.name == "no" {
            messageBoard.isHidden = true
            settingBoard.isHidden = false
        }
    }
}
