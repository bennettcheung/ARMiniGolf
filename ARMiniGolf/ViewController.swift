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
  @IBOutlet weak var ballHitForceProgressView: UIProgressView!
    
  var planeNodes = [SCNNode]()
  var globalBallNode: SCNNode!
  var courseNode: SCNNode!
  var longPressGestureRecognizer = UILongPressGestureRecognizer()
  var tapGestureRecognizer = UITapGestureRecognizer()
  var ballExists = false
  var pressStartTime:Date?
  var timeSinceLastHaptic: Date?
  let lightFeedback = UIImpactFeedbackGenerator(style: .light)
  var hapticsInterval = Float()
  var sounds:[String:SCNAudioSource] = [:]
  
  var gameManager = GameManager()
  
  // TODO: Declare  node name constant
  let courseNodeName = "course"
  
  // TODO: Initialize an empty array of type SCNNode
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //debug code
    sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin, .showPhysicsShapes]
    
    addTapGestureToSceneView()
    configureLighting()
    addLongPressGesturesToSceneView()
    self.ballHitForceProgressView.alpha = 0
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
//    let configuration = ARWorldTrackingConfiguration()
//    let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
//    sceneView.session.run(configuration, options: options)

    sceneView.debugOptions = []
  }
  
  func configureLighting() {
    sceneView.autoenablesDefaultLighting = true
    sceneView.automaticallyUpdatesLighting = true
  }
  
  func setupSounds(){
    let puttSound = SCNAudioSource(fileNamed: "putt.wav")!
    puttSound.load()
    puttSound.volume = 0.6
    
    sounds["putt"] = puttSound
    
    let backgroundMusic = SCNAudioSource(fileNamed: "background.mp3")!
    backgroundMusic.volume = 0.3
    backgroundMusic.loops = true
    backgroundMusic.load()
    
    let musicPlayer = SCNAudioPlayer(source: backgroundMusic)
    courseNode.addAudioPlayer(musicPlayer)
    
  }
  
  
  
  func addTapGestureToSceneView() {
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addCourseToSceneView(withGestureRecognizer:)))
    sceneView.addGestureRecognizer(tapGestureRecognizer)
  }
  

  // Add long press gestures to scene view method
  func addLongPressGesturesToSceneView() {
    longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.applyForceToBall(withGestureRecognizer:)))
    longPressGestureRecognizer.minimumPressDuration = 0.5
    
 
    
    sceneView.addGestureRecognizer(self.longPressGestureRecognizer)
  }
  
  func addPinchGestureToSceneView(){
    let pinchGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handlePinch))
    sceneView.addGestureRecognizer(pinchGestureRecognizer)
    
  }
  
  @objc func addCourseToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
    //Don't continue if game already started
    if gameManager.gameStarted()  {
      return
    }
    
    let tapLocation = recognizer.location(in: sceneView)
    let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
    guard let hitTestResult = hitTestResults.first else { return }
    
    let translation = hitTestResult.worldTransform.translation
    let x = translation.x
    let y = translation.y + 0.05
    let z = translation.z - 0.5
    

    guard let courseScene = SCNScene(named: "art.scnassets/course.scn"),
      let courseNode = courseScene.rootNode.childNode(withName: "course", recursively: false)
      else { return }

    
    courseNode.position = SCNVector3(x,y,z)
    
    // TODO: Attach physics body to course node
    let physicsBody = SCNPhysicsBody(type: .static, shape: nil)
//    physicsBody.restitution = 0.1
    courseNode.physicsBody = physicsBody
    
//    courseNode.physicsBody?.isAffectedByGravity = false  //TEST CODE
    
    courseNode.name = courseNodeName
    
    sceneView.scene.rootNode.addChildNode(courseNode)
    
    self.courseNode = courseNode
    
    //add ball to the course
    guard let ballScene = SCNScene(named: "art.scnassets/ball.scn"),
      let ballNode = ballScene.rootNode.childNode(withName: "ball", recursively: false)
      else { return }
    globalBallNode = ballNode
    globalBallNode.position = SCNVector3(courseNode.position.x, courseNode.position.y, courseNode.position.z + 2.1)
    //globalBallNode.physicsBody?.continuousCollisionDetectionThreshold
    //ballNode.position = SCNVector3(courseNode.position.x, courseNode.position.y, courseNode.position.z + 2.1)
    sceneView.scene.rootNode.addChildNode(ballNode)
    
    //start game, remove the detecting plane node
    turnoffARPlaneTracking()
    setupSounds()
    gameManager.startGame()
  }
  
  
  @objc func handlePinch(_ recognizer: UIGestureRecognizer) {
    //Don't continue if game already started
    print("pinch gesture handler called")
    if gameManager.gameStarted()  {
      return
    }
    
  }
  //*************************************************************************** direction and force for ball path *********************************
  
  // Get user vector
  
  func getUserVector() -> (SCNVector3) {
    if let frame = self.sceneView.session.currentFrame {
      let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
      var direction = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
      //let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
      direction.y = 0 //negate height
      return (direction)
    }
    return (SCNVector3(0, 0, -1))
  }
  
  
  // Get ball node from long press location method
  func getBallNode(from longPressLocation: CGPoint) -> SCNNode? {
    let hitTestResults = sceneView.hitTest(longPressLocation)
    guard let parentNode  = hitTestResults.first?.node.parent
      else { return nil }
    for child in parentNode.childNodes {
      if child.name == "ball" {
        return child
      }
    }
    return nil
  }
  
  //Apply force to ball method
  
  @objc func applyForceToBall(withGestureRecognizer recognizer: UIGestureRecognizer) {
    print("above state began")
    //button press state begins

    if recognizer.state == .began {
        print("State begin")
      pressStartTime = Date()
    }
   
    guard let physicsBody = globalBallNode.physicsBody
      else { return }
    globalBallNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
    var direction = self.getUserVector()
    let duration = getHoldDuration()
    hapticsInterval = Float(getAppropriateFeedback(duration: duration))
    let force = 1/hapticsInterval
    updateForceIndicator(force: force)
    print("All commands for begin have run")
    
    //button press state ends
    
    if recognizer.state == .ended {
        print("state ended")
      globalBallNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
      self.ballHitForceProgressView.alpha = 0
      let forceMultiplier = force * 0.05 //adjust the distance the ball is hit
      direction.x = direction.x * forceMultiplier
      direction.z = direction.z * forceMultiplier
      print (direction)
      
      //play a sound and apply force
      let puttSound =  sounds["putt"]!
      globalBallNode.runAction(SCNAction.playAudio(puttSound, waitForCompletion: false))
      physicsBody.applyForce(direction, asImpulse: true)
      self.ballHitForceProgressView.setProgress(0, animated: false)
    }


  }
    
    func updateForceIndicator (force: Float){
        //self.ballHitForceProgressView.setProgress(0, animated: false)
        self.ballHitForceProgressView.clipsToBounds = true
        self.ballHitForceProgressView.layer.cornerRadius = 5
        self.ballHitForceProgressView.alpha = 1
        UIView.animate(withDuration: 0.5) { self.ballHitForceProgressView.setProgress(force/10, animated: true) }
        //self.ballHitForceProgressView.progress = force/10
        
    }
    
    func getHoldDuration() -> Float {
        guard let pressStartTime = pressStartTime else {
            print ("Timer not created")
            return 0
        }
        let duration = -Float(pressStartTime.timeIntervalSinceNow)
        return duration
        
    }
    func getAppropriateFeedback(duration:Float) -> TimeInterval{
        let interval: TimeInterval
        switch duration {
        case 0.5...1:
            interval = 0.4
        case 1...2:
            interval = 0.2
        case 2...:
            interval = 0.1
        default:
            interval = 1.0
        }
        if let prevTime = timeSinceLastHaptic {
            if Date().timeIntervalSince(prevTime) > interval {
                lightFeedback.impactOccurred()
                timeSinceLastHaptic = Date()
            }
        } else {
            lightFeedback.impactOccurred()
            timeSinceLastHaptic = Date()
        }
        return interval
    }
    
    @IBAction func resetBallLocationButton(_ sender: Any) {
        globalBallNode.position = SCNVector3(courseNode.position.x, courseNode.position.y, courseNode.position.z + 2.1)
    }
    
}

//********************************* MARK: Plane Rendering

extension ViewController: ARSCNViewDelegate {
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard  let planeAnchor = anchor as? ARPlaneAnchor else { return }
    
    let width = CGFloat(planeAnchor.extent.x)
    let height = CGFloat(planeAnchor.extent.z)
    let plane = SCNPlane(width: width, height: height)
    
    plane.materials.first?.diffuse.contents = UIColor.transparentWhite
    
    var planeNode = SCNNode(geometry: plane)
    
    let x = CGFloat(planeAnchor.center.x)
    let y = CGFloat(planeAnchor.center.y)
    let z = CGFloat(planeAnchor.center.z)
    planeNode.position = SCNVector3(x,y,z)
    planeNode.eulerAngles.x = -.pi / 2
    
    // TODO: Update plane node
    update(&planeNode, withGeometry: plane, type: .static)
    
    node.addChildNode(planeNode)
    
    // TODO: Append plane node to plane nodes array if appropriate
      planeNodes.append(planeNode)
  }
  
  // TODO: Remove plane node from plane nodes array if appropriate
  func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
      guard anchor is ARPlaneAnchor,
          let planeNode = node.childNodes.first
          else { return }
      planeNodes = planeNodes.filter { $0 != planeNode }
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
