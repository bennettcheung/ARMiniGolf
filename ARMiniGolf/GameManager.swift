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
  
  override init() {
    state = State.Detecting
  }
  
  func startGame(){
    state = State.Started
  }
  
  func gameStarted() -> Bool{
    return state == State.Started
  }
}
