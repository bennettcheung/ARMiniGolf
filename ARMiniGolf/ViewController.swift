//
//  ViewController.swift
//  ARMiniGolf
//
//  Created by Bennett on 2018-09-20.
//  Copyright © 2018 iNomad Studio. All rights reserved.
//
//

import UIKit
import ARKit


class ViewController: UIViewController {
  
  @IBOutlet weak var sceneView: ARSCNView!
  
  var planeNode = SCNNode()
  var ballNode: SCNNode!
  var courseNode: SCNNode!
  
  var gameManager = GameManager()
  
  // TODO: Declare rocketship node name constant
  let courseNodeName = "course"
  let rocketNodeName = "ball"
  
  // TODO: Initialize an empty array of type SCNNode
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //debug code
    sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin, .showPhysicsShapes]
    
    addTapGestureToSceneView()
    configureLighting()
    addSwipeGesturesToSceneView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setUpSceneView()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    sceneView.session.pause()
  }
  
  func setUpSceneView() {
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    
    sceneView.session.run(configuration)
    
    sceneView.delegate = self
  }
  
  func turnoffARPlaneTracking(){
    let configuration = ARWorldTrackingConfiguration()
    let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
    sceneView.session.run(configuration, options: options)

  }
  
  func configureLighting() {
    sceneView.autoenablesDefaultLighting = true
    sceneView.automaticallyUpdatesLighting = true
  }
  
  func addTapGestureToSceneView() {
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addCourseToSceneView(withGestureRecognizer:)))
    sceneView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  // TODO: Create add swipe gestures to scene view method
  func addSwipeGesturesToSceneView() {
    let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.applyForceToBall(withGestureRecognizer:)))
    swipeUpGestureRecognizer.direction = .up
    sceneView.addGestureRecognizer(swipeUpGestureRecognizer)
    
  }
  
  @objc func addCourseToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
    //Don't continue if game already started
    if gameManager.gameStarted(){
      //add ball if the game already started
      guard let ballScene = SCNScene(named: "art.scnassets/ball.scn"),
        let ballNode = ballScene.rootNode.childNode(withName: "ball", recursively: false)
        else { return }
      
      
      ballNode.position = SCNVector3(courseNode.position.x-1, courseNode.position.y + 0.03, courseNode.position.z + 0.02)
      sceneView.scene.rootNode.addChildNode(ballNode)
      //      let physicsBody = SCNPhysicsBody(type: .dynamic, shape: )
      //      ballNode.physicsBody = physicsBody
      return
    }

    
    let tapLocation = recognizer.location(in: sceneView)
    let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
    guard let hitTestResult = hitTestResults.first else { return }
    
    let translation = hitTestResult.worldTransform.translation
    let x = translation.x
    let y = translation.y + 0.05
    let z = translation.z
    

    guard let courseScene = SCNScene(named: "art.scnassets/course.scn"),
      let courseNode = courseScene.rootNode.childNode(withName: "course", recursively: false)
      else { return }

    
    courseNode.position = SCNVector3(x,y,z)

    
    // TODO: Attach physics body to rocketship node
    let physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
    physicsBody.restitution = 0.1
    courseNode.physicsBody = physicsBody
    
    courseNode.physicsBody?.isAffectedByGravity = false  //TEST CODE
    
    courseNode.name = courseNodeName
    
    sceneView.scene.rootNode.addChildNode(courseNode)
    
    self.courseNode = courseNode
    
    //create ball node
//    guard let ballScene = SCNScene(named: "art.scnassets/ball.scn"),
//      let ballNode = ballScene.rootNode.childNode(withName: "ball", recursively: false)
//    else { print("ball not found")
//      return }
//    ballNode.position = SCNVector3(x,y,z)
//    sceneView.scene.rootNode.addChildNode(ballNode)

    
    //start game, remove the detecting plane node
    turnoffARPlaneTracking()
    gameManager.startGame()
  }

  
  // TODO: Create get rocketship node from swipe location method
  func getRocketshipNode(from swipeLocation: CGPoint) -> SCNNode? {
    let hitTestResults = sceneView.hitTest(swipeLocation)
    guard let parentNode = hitTestResults.first?.node.parent
    
      else { return nil }
    guard  parentNode.name == rocketNodeName else{
      return nil
    }
    return parentNode
  }
  
  // TODO: Create apply force to rocketship method
  @objc func applyForceToBall(withGestureRecognizer recognizer: UIGestureRecognizer) {
    // 1
    guard recognizer.state == .ended else { return }
    // 2
    let swipeLocation = recognizer.location(in: sceneView)
    // 3
    guard let rocketshipNode = getRocketshipNode(from: swipeLocation),
      let physicsBody = rocketshipNode.physicsBody
      else { return }
    // 4
    let direction = SCNVector3(0, 0, -1)
    physicsBody.applyForce(direction, asImpulse: true)
//    guard let physicsBody = ballNode.physicsBody
//      else { return }
//    // 4
//    physicsBody.isAffectedByGravity = false
//    let direction = SCNVector3(0, 0, -1)
//    physicsBody.applyForce(direction, asImpulse: true)
        ballNode = rocketshipNode
  }
  

}

extension ViewController: ARSCNViewDelegate {
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard  let planeAnchor = anchor as? ARPlaneAnchor else { return }
    
    let width = CGFloat(planeAnchor.extent.x)
    let height = CGFloat(planeAnchor.extent.z)
    let plane = SCNPlane(width: width, height: height)
    
    plane.materials.first?.diffuse.contents = UIColor.transparentWhite
    
    planeNode = SCNNode(geometry: plane)
    
    let x = CGFloat(planeAnchor.center.x)
    let y = CGFloat(planeAnchor.center.y)
    let z = CGFloat(planeAnchor.center.z)
    planeNode.position = SCNVector3(x,y,z)
    planeNode.eulerAngles.x = -.pi / 2
    
    // TODO: Update plane node
    update(&planeNode, withGeometry: plane, type: .static)
    
    node.addChildNode(planeNode)
    
    // TODO: Append plane node to plane nodes array if appropriate
            //planeNodes.append(planeNode)
  }
  
  // TODO: Remove plane node from plane nodes array if appropriate
  func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
//            guard anchor is ARPlaneAnchor,
//                let planeNode = node.childNodes.first
//                else { return }
//            planeNodes = planeNodes.filter { $0 != planeNode }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as?  ARPlaneAnchor,
      var planeNode = node.childNodes.first,
      let plane = planeNode.geometry as? SCNPlane
      else { return }
    
    let width = CGFloat(planeAnchor.extent.x)
    let height = CGFloat(planeAnchor.extent.z)
    plane.width = width
    plane.height = height
    
    let x = CGFloat(planeAnchor.center.x)
    let y = CGFloat(planeAnchor.center.y)
    let z = CGFloat(planeAnchor.center.z)
    
    planeNode.position = SCNVector3(x, y, z)
    
    update(&planeNode, withGeometry: plane, type: .static)
    
  }
  
  // TODO: Create update plane node method
  func update(_ node: inout SCNNode, withGeometry geometry: SCNGeometry, type: SCNPhysicsBodyType) {
    let shape = SCNPhysicsShape(geometry: geometry, options: nil)
    let physicsBody = SCNPhysicsBody(type: type, shape: shape)
    node.physicsBody = physicsBody
  }
}

extension float4x4 {
  var translation: float3 {
    let translation = self.columns.3
    return float3(translation.x, translation.y, translation.z)
  }
}

extension UIColor {
  open class var transparentWhite: UIColor {
    return UIColor.white.withAlphaComponent(0.20)
  }
}
