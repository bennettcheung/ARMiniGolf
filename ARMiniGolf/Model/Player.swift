//
//  Player.swift
//  ARMiniGolf
//
//  Created by Bennett on 2018-09-23.
//  Copyright © 2018 iNomad Studio. All rights reserved.
//

import UIKit

class Player: NSObject {
  var name: String
  var score: Int
  
  init(name: String, score: Int) {
    self.name = name
    self.score = score
    super.init()
  }

}
