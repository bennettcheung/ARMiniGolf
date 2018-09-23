//
//  GameBoard.swift
//  ARMiniGolf
//
//  Created by Bennett on 2018-09-22.
//  Copyright © 2018 iNomad Studio. All rights reserved.
//

import UIKit

class GameBoard: NSObject {
  /// The minimum size of the board in meters
  static let minimumScale: Float = 0.3
  
  /// The maximum size of the board in meters
  static let maximumScale: Float = 11.0 // 15x27m @ 10, 1.5m x 2.7m @ 1

  
  /// The level's preferred size.
  /// This is used both to set the aspect ratio and to determine
  /// the default size.
//  var preferredSize: CGSize = CGSize(width: 1.5, height: 2.7) {
//    didSet {
//      updateBorderAspectRatio()
//    }
//  }
//  
//  /// The aspect ratio of the level.
//  var aspectRatio: Float { return Float(preferredSize.height / preferredSize.width) }
//  
//  /// Incrementally scales the board by the given amount
//  func scale(by factor: Float) {
//    // assumes we always scale the same in all 3 dimensions
//    let currentScale = simdScale.x
//    let newScale = clamp(currentScale * factor, GameBoard.minimumScale, GameBoard.maximumScale)
//    simdScale = float3(newScale)
//  }
//  
//  
//  private func orientToPlane(_ planeAnchor: ARPlaneAnchor, camera: ARCamera) {
//    // Get board rotation about y
//    simdOrientation = simd_quatf(planeAnchor.transform)
//    var boardAngle = simdEulerAngles.y
//    
//    // If plane is longer than deep, rotate 90 degrees
//    if planeAnchor.extent.x > planeAnchor.extent.z {
//      boardAngle += .pi / 2
//    }
//    
//    // Normalize angle to closest 180 degrees to camera angle
//    boardAngle = boardAngle.normalizedAngle(forMinimalRotationTo: camera.eulerAngles.y, increment: .pi)
//    
//    rotate(to: boardAngle)
//  }
//  
//  private func rotate(to angle: Float) {
//    // Avoid interpolating between angle flips of 180 degrees
//    let previouAngle = recentRotationAngles.reduce(0, { $0 + $1 }) / Float(recentRotationAngles.count)
//    if abs(angle - previouAngle) > .pi / 2 {
//      recentRotationAngles = recentRotationAngles.map { $0.normalizedAngle(forMinimalRotationTo: angle, increment: .pi) }
//    }
//    
//    // Average using several most recent rotation angles.
//    recentRotationAngles.append(angle)
//    recentRotationAngles = Array(recentRotationAngles.suffix(20))
//    
//    // Move to average of recent positions to avoid jitter.
//    let averageAngle = recentRotationAngles.reduce(0, { $0 + $1 }) / Float(recentRotationAngles.count)
//    simdRotation = float4(0, 1, 0, averageAngle)
//  }
//  
//  private func scaleToPlane(_ planeAnchor: ARPlaneAnchor) {
//    // Determine if extent should be flipped (plane is 90 degrees rotated)
//    let planeXAxis = planeAnchor.transform.columns.0.xyz
//    let axisFlipped = abs(dot(planeXAxis, simdWorldRight)) < 0.5
//    
//    // Flip dimensions if necessary
//    var planeExtent = planeAnchor.extent
//    if axisFlipped {
//      planeExtent = vector3(planeExtent.z, 0, planeExtent.x)
//    }
//    
//    // Scale board to the max extent that fits in the plane
//    var width = min(planeExtent.x, GameBoard.maximumScale)
//    let depth = min(planeExtent.z, width * aspectRatio)
//    width = depth / aspectRatio
//    simdScale = float3(width)
//    
//    // Adjust position of board within plane's bounds
//    var planeLocalExtent = float3(width, 0, depth)
//    if axisFlipped {
//      planeLocalExtent = vector3(planeLocalExtent.z, 0, planeLocalExtent.x)
//    }
//    adjustPosition(withinPlaneBounds: planeAnchor, extent: planeLocalExtent)
//  }
}
