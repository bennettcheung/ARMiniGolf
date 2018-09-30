//
//  Level.swift
//  ARMiniGolf
//
//  Created by Bennett on 2018-09-27.
//  Copyright © 2018 iNomad Studio. All rights reserved.
//

import Foundation
import SceneKit

class Level{
  let sceneFile: String
  let musicFile: String
  var initialCourseOffset: SCNVector3
  let initialBallOffset: SCNVector3
  var scale: Float
  
  init(sceneFile: String, musicFile: String, initialCourseOffset: SCNVector3, initialBallOffset: SCNVector3, scale: Float) {
    self.sceneFile = sceneFile
    self.musicFile = musicFile
    self.scale = scale
    var ballOffsetWithScale = initialBallOffset
    ballOffsetWithScale.x *= scale
    ballOffsetWithScale.z *= scale
    self.initialCourseOffset = initialCourseOffset
    self.initialBallOffset = ballOffsetWithScale
  }
}
