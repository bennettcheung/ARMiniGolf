//
//  ViewController.swift
//  ARMiniGolf
//
//  Created by Bennett on 2018-09-20.
//  Copyright © 2018 iNomad Studio. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    var ground: SCNNode!
    var grids = [Grid]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        //configure lighting
      configureLighting()
      
        // Create a new scene
      let scene = SCNScene(named: "art.scnassets/ball.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
      
      //add gesture recognizer
      let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
      sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
  
  func configureLighting() {
    sceneView.autoenablesDefaultLighting = true
    sceneView.automaticallyUpdatesLighting = true
  }


    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
  
  // 1.
  @objc func tapped(gesture: UITapGestureRecognizer) {
    // Get exact position where touch happened on screen of iPhone (2D coordinate)
    let touchPosition = gesture.location(in: sceneView)
    // 2.
    let hitTestResult = sceneView.hitTest(touchPosition, types: .featurePoint)
    
    if !hitTestResult.isEmpty {
      
      guard let hitResult = hitTestResult.first else {
        return
      }
      
      addBall(hitTestResult: hitResult)
    }
  }
  
  // 1.
  func addBall(hitTestResult: ARHitTestResult) {
    let scene = SCNScene(named: "art.scnassets/ball.scn")!
    let grassNode = scene.rootNode.childNode(withName: "ball", recursively: true)
    grassNode?.position = SCNVector3(hitTestResult.worldTransform.columns.3.x,hitTestResult.worldTransform.columns.3.y, hitTestResult.worldTransform.columns.3.z)

    // 2.
    self.sceneView.scene.rootNode.addChildNode(grassNode!)
  }
  
  func addBall(position: SCNVector3){
    let scene = SCNScene(named: "art.scnassets/ball.scn")!
    let ballNode = scene.rootNode.childNode(withName: "ball", recursively: true)
    ballNode?.position = position
    self.sceneView.scene.rootNode.addChildNode(ballNode!)
  }

}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate{
  // 1.
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

    if grids.count <= 0 {
      
    
      let grid = Grid(anchor: anchor as! ARPlaneAnchor)
      self.grids.append(grid)
      node.addChildNode(grid)
    print("Grid did Add")
    }
//    addBall(position: grid.position)
  }
  // 2.
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    let grid = self.grids.filter { grid in
      return grid.anchor.identifier == anchor.identifier
      }.first
    
    guard let foundGrid = grid else {
      return
    }
    
    foundGrid.update(anchor: anchor as! ARPlaneAnchor)
  }
}
