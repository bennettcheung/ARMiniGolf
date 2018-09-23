//
//  GameManager.swift
//  ARMiniGolf
//
//  Created by Bennett on 2018-09-21.
//  Copyright © 2018 iNomad Studio. All rights reserved.
//

import UIKit

enum State {
  case Detecting
  case Started
}

class GameManager: NSObject {
  var state: State
  private var currentPlayer: Player!
  
  override init() {
    state = State.Detecting
    currentPlayer = Player(name: "Player 1", score: 0)
    super.init()
  }
  
  func startGame(){
    state = State.Started
  }
  
  func restartGame(){
    currentPlayer.score = 0
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
}
