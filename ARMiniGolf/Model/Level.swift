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
  let initialCourseOffset: SCNVector3
  let initialBallOffset: SCNVector3
  var scale: Float
  
  init(sceneFile: String, musicFile: String, initialCourseOffset: SCNVector3, initialBallOffset: SCNVector3, scale: Float) {
    self.sceneFile = sceneFile
    self.musicFile = musicFile
    self.scale = scale
    
    var courseOffsetWIthScale = initialCourseOffset
    courseOffsetWIthScale.x *= scale
    courseOffsetWIthScale.y *= scale
    courseOffsetWIthScale.z *= scale
    self.initialCourseOffset = courseOffsetWIthScale
    
    var ballOffsetWithScale = initialBallOffset
    ballOffsetWithScale.x *= scale
    ballOffsetWithScale.z *= scale
    self.initialBallOffset = ballOffsetWithScale
  }
}
