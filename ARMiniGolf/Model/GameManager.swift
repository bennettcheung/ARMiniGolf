//
//  GameManager.swift
//  ARMiniGolf
//
//  Created by Bennett on 2018-09-21.
//  Copyright © 2018 iNomad Studio. All rights reserved.
//

import UIKit
import SceneKit

enum State {
  case Detecting
  case Started
  case Ended
}

class GameManager: NSObject {
  var state: State
  private var currentPlayer: Player!
  private var levels = [Level]()
  private var currentLevelNum: Int = 1
  override init() {
    state = State.Detecting
    currentPlayer = Player(name: "Player 1", score: 0)
    super.init()
    initLevels()
  }
  
  private func initLevels(){
    //hard code the levels
    levels = [
      Level.init(sceneFile: "art.scnassets/course.scn", musicFile: "background.mp3", initialCourseOffset: SCNVector3(0, 0.05, -2.5),
                         initialBallOffset: SCNVector3(0, 0, 3.8), scale: 1),  // Level 1
      Level.init(sceneFile: "art.scnassets/course2.scn", musicFile: "background2.mp3", initialCourseOffset: SCNVector3(0, 0, -2),
                 initialBallOffset: SCNVector3(-0.5, 0.2, 2.7), scale: 1),  // Level 2
      Level.init(sceneFile: "art.scnassets/course3.scn", musicFile: "background3.mp3", initialCourseOffset: SCNVector3(0, 0, 0),
                  initialBallOffset: SCNVector3(0, 0.2, -3.924), scale: 1) // Level 3
    ]
  }
  
  func startGame(){
    state = State.Started
  }
  
  func restartGame(){
    currentPlayer.score = 0
  }
  
  func endGame(){
    state = State.Ended
  }
  
  func incrementShotCount(){
    currentPlayer.score += 1
  }
  
  func getCurrentPlayerScore() -> Int{
    return currentPlayer.score
  }
  
  func gameStarted() -> Bool{
    return state == State.Started
  }
  
  func gameEnded() -> Bool{
    return state == State.Ended
  }
  
    func setLevel(_ level: Int){
        if level > 0 && level <= levels.count{
            self.currentLevelNum = level
        }
    }
    
  func getCurrentLevel() ->Level {
    return levels[currentLevelNum - 1]
  }
  
  func advanceLevel(){
    currentPlayer.score = 0
    if currentLevelNum < levels.count{
      currentLevelNum += 1
    }
    else{
      currentLevelNum = 1
    }
  }
}
