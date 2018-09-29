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
  private let initialCourseOffset: SCNVector3
  private let initialBallOffset: SCNVector3
  var scaledCourseOffset: SCNVector3
  var scaledBallOffset: SCNVector3
  let width: Float
  let height: Float
  var scale: Float = 1
  
  init(sceneFile: String, musicFile: String, width: Float, height: Float, initialCourseOffset: SCNVector3, initialBallOffset: SCNVector3) {
    self.sceneFile = sceneFile
    self.musicFile = musicFile
    self.width = width
    self.height = height
    self.initialCourseOffset = initialCourseOffset
    self.initialBallOffset = initialBallOffset
    scaledBallOffset = SCNVector3(x: initialBallOffset.x, y: initialBallOffset.y, z: initialBallOffset.z)
    scaledCourseOffset = SCNVector3(x: initialCourseOffset.x, y: initialCourseOffset.y, z: initialCourseOffset.z)
  }
  
  func calculateScale(planeWidth: CGFloat, planeHeight: CGFloat, pitchScale: Float){
    let widthRatio = Float(planeWidth) * pitchScale / width
    let heightRatio = Float(planeHeight) * pitchScale / height
    
    //take the larger ratio
    scale = widthRatio > heightRatio ? widthRatio : heightRatio
    
    self.scaledBallOffset.x *= scale
    self.scaledBallOffset.y *= scale
    self.scaledBallOffset.z *= scale
    
    self.scaledCourseOffset.x *= scale
    self.scaledCourseOffset.y *= scale
    self.scaledCourseOffset.z *= scale
    
    print("Scale is \(scale)")
  }
}
