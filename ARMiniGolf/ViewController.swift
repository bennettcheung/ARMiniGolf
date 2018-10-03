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
    
    //MARK: Outlets
    
    @IBOutlet weak var touchTheScreenImageView: UIImageView!
    @IBOutlet weak var resetGameButton: UIButton!
    @IBOutlet weak var handAndPhoneImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var ballHitForceProgressView: UIProgressView!
    
    //MARK: Variables and Constants
    
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
    let courseNodeName = "course"
    let sceneManager = ARSceneManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addGesturesToSceneView()
        sceneManager.attach(to: sceneView)
      sceneView.debugOptions = [.showFeaturePoints, .showPhysicsShapes]
        sceneManager.displayDebugInfo()
        sceneManager.startPlaneDetection()
       sceneView.scene.physicsWorld.contactDelegate = self
        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
         */
        UIApplication.shared.isIdleTimerDisabled = true
      
        ballHitForceProgressView.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showPhoneMovementDemo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //sceneView.session.pause()
    }
    
    func setLevel(_ level: Int){
        gameManager.setLevel(level)
    }

    
    // MARK: Turn Off Debugging
    
    func turnoffARPlaneTracking(){
        if handAndPhoneImageView != nil && touchTheScreenImageView != nil{
            handAndPhoneImageView.removeFromSuperview()
            touchTheScreenImageView.layer.removeAllAnimations()
            touchTheScreenImageView.removeFromSuperview()
        }
        
       sceneManager.stopPlaneDetection()
       sceneManager.showPlanes = false
      sceneManager.hideDebugInfo()
    }
    
    // MARK: Phone Animations
    
    func showPhoneMovementDemo(){
        if handAndPhoneImageView != nil && touchTheScreenImageView != nil{
            touchTheScreenImageView.alpha = 0
            messageLabel.text = "Move the phone side to side repeatedly while the game is searching for a flat surface."
            let centerX = self.view.center.x
            let handY = handAndPhoneImageView.center.y
            handAndPhoneImageView.center = CGPoint(x: centerX, y: handY)
            UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseOut], animations: {
                self.handAndPhoneImageView.center.x += 150
            }, completion: nil)
            UIView.animate(withDuration: 3, delay: 1.5, options: [.autoreverse, .repeat, .curveEaseInOut], animations: {
                self.handAndPhoneImageView.center.x -= 280
            }, completion: nil)
        }
    }
    
    func showPhoneWithClickingDemo(){
        if handAndPhoneImageView != nil && touchTheScreenImageView != nil{
            messageLabel.text = "Now tap on the white rectangle to place the MiniGolf course."
            handAndPhoneImageView.layer.removeAllAnimations()
            handAndPhoneImageView.center.x = self.view.center.x
            touchTheScreenImageView.center.x = handAndPhoneImageView.center.x - 5
            UIView.animate(withDuration: 2, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.touchTheScreenImageView.alpha = 1
            })
        }
    }
    
    
    // MARK: Setup Music/Sound
    
    func setupSounds(){
        let puttSound = SCNAudioSource(fileNamed: "putt.wav")!
        puttSound.load()
        puttSound.volume = 0.6
        sounds["putt"] = puttSound
        let ballInHoleSound = SCNAudioSource(fileNamed: "ballInHole.wav")!
        ballInHoleSound.load()
        ballInHoleSound.volume = 0.4
        sounds["ballInHole"] = ballInHoleSound
        loadBackgroundMusic()
    }
    
    func loadBackgroundMusic(){
        let level = gameManager.getCurrentLevel()
        let backgroundMusic = SCNAudioSource(fileNamed: level.musicFile)!
        backgroundMusic.volume = 0.3
        backgroundMusic.loops = true
        backgroundMusic.load()
        let musicPlayer = SCNAudioPlayer(source: backgroundMusic)
        courseNode.addAudioPlayer(musicPlayer)
    }
    
    // MARK: Setup Gestures
    
    func addGesturesToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addCourseToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.applyForceToBall(withGestureRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        sceneView.addGestureRecognizer(self.longPressGestureRecognizer)

    }

    // MARK:  Setup, Add course / Start Game
    
    @objc func addCourseToSceneView(withGestureRecognizer gesture: UIGestureRecognizer) {
        //Don't continue if game already started
        if gameManager.gameStarted()  {
            return
        }
        // screen setup
        messageLabel.text = ""
        scoreLabel.text = "0"
        scoreLabel.alpha = 0.7
        resetGameButton.alpha = 1
        
      if gesture.state == .ended{
        // get tap location
        let tapLocation = gesture.location(ofTouch: 0, in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingGeometry)
        guard let hitTestResult = hitTestResults.first else { return }

        // drop the course at the location

        let position = SCNVector3Make(hitTestResult.worldTransform.columns.3.x ,
                hitTestResult.worldTransform.columns.3.y ,
                hitTestResult.worldTransform.columns.3.z )
        
        let transform = SCNMatrix4(hitTestResult.anchor!.transform)
        addCourseAtPosition(position, transform)
        addBallToScene()
        
        //start game, remove the detecting plane node
        turnoffARPlaneTracking()
        setupSounds()
        gameManager.startGame()
      }
    }
  
  private func addCourseAtPosition(_ position: SCNVector3, _ transform: SCNMatrix4){
        //if we are advancing to a different level
        if courseNode != nil{
            courseNode.removeFromParentNode()
            courseNode.removeAllAudioPlayers()
            courseNode = nil
        }
        let level = gameManager.getCurrentLevel()
        guard let courseScene = SCNScene(named: level.sceneFile)
            else { return }
        courseNode = courseScene.rootNode.childNode(withName: "course", recursively: false)
    
        //TO DO courseNode.transform = transform
        // MARK: Physics Body Scaling
        
        if level.scale != 1 {
            courseNode.scale = SCNVector3(level.scale, level.scale, level.scale)
          
            for node in courseNode.childNodes{
                print("\(node.name ?? "No node name") \(node.geometry?.description ?? "No node geometry") ")
                if let printPhysicsBody = node.physicsBody, let printPhysicsShape = printPhysicsBody.physicsShape {
                  print ("\(printPhysicsShape.description)")
                }
                if let physicsBody = node.physicsBody, let geometry = node.geometry{
                    if node.name == "redTube" || node.name == "interiorRightTube" || node.name == "interiorLeftTube" || node.name == "exteriorWalls"
                    {
                        physicsBody.physicsShape = SCNPhysicsShape(geometry: geometry, options: [SCNPhysicsShape.Option.scale: SCNVector3(level.scale, level.scale, level.scale), SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
                    }
//                    else if node.name == "flagPole"{
//                        physicsBody.physicsShape = SCNPhysicsShape(geometry: geometry, options: [SCNPhysicsShape.Option.scale: SCNVector3(level.scale, level.scale, level.scale), SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.convexHull])
//                    }
                    else if node.name != "floor"{
                        physicsBody.physicsShape = SCNPhysicsShape(geometry: geometry, options: [SCNPhysicsShape.Option.scale: SCNVector3(level.scale, level.scale, level.scale)])
                    }

                  print ("category \(physicsBody.categoryBitMask) collision \(physicsBody.collisionBitMask) contact \(physicsBody.contactTestBitMask)")
                }
            }
        }
        courseNode.position = position
//        courseNode.position.z = position.z - 0.5
//        courseNode.position.y = position.y - 0.5

        courseNode.name = courseNodeName
    
       sceneView.scene.rootNode.addChildNode(courseNode)
    }
    
    // MARK: Add Ball To Scene
    
    private func addBallToScene(){
        if globalBallNode != nil{
            globalBallNode.removeFromParentNode()
        }
        guard let ballScene = SCNScene(named: "art.scnassets/ball.scn"),
            let ballNode = ballScene.rootNode.childNode(withName: "ball", recursively: false)
            else { return }
        globalBallNode = ballNode
        let level = gameManager.getCurrentLevel()
        if level.scale != 1 {
        globalBallNode.scale = SCNVector3(level.scale*2, level.scale*2, level.scale*2)
        }
        sceneView.scene.rootNode.addChildNode(ballNode)
        
        globalBallNode.physicsBody?.continuousCollisionDetectionThreshold = 0.01
      
      if let physicsBody = globalBallNode.physicsBody{
      print ("category \(physicsBody.categoryBitMask) collision \(physicsBody.collisionBitMask) contact \(physicsBody.contactTestBitMask)")
      }
        resetBallToInitialLocation()
    }
    
    // MARK: Ball Direction and Force
    
    // Get user vector
    
    func getUserVector() -> (SCNVector3) {
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            var direction = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            direction.y = 0 //negate height
            return (direction)
        }
        return (SCNVector3(0, 0, -1))
    }
    
    //Apply force to ball method
    
    @objc func applyForceToBall(withGestureRecognizer recognizer: UIGestureRecognizer) {
        //button press state begins
        if recognizer.state == .began {
            pressStartTime = Date()
            DispatchQueue.main.async {
                self.messageLabel.text = ""
            }
        }
        guard let physicsBody = globalBallNode.physicsBody
            else { return }
        globalBallNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        var direction = self.getUserVector()
        let duration = getHoldDuration()
        hapticsInterval = Float(getAppropriateFeedback(duration: duration))
        let force = 1/hapticsInterval
        updateForceIndicator(force: force)
        
        //button press state ends
        
        if recognizer.state == .ended {
            
            //play a sound and apply force
            let puttSound =  sounds["putt"]!
            globalBallNode.runAction(SCNAction.playAudio(puttSound, waitForCompletion: false))
            globalBallNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            self.ballHitForceProgressView.alpha = 0
            
            //-------------------------
            
            let level = gameManager.getCurrentLevel()
            var forceMultiplier = force
            if level.scale != 1 {
            forceMultiplier = force * 0.05
            }else{
                forceMultiplier = force * 0.05 * level.scale
            }//adjust the distance the ball is hit
            
            //-------------------------
            
        
            direction.x = direction.x * forceMultiplier
            direction.z = direction.z * forceMultiplier
            physicsBody.applyForce(direction, asImpulse: true)
            self.ballHitForceProgressView.setProgress(0, animated: false)
            normalStroke()
        }
    }
    
    func updateForceIndicator (force: Float){
        self.ballHitForceProgressView.clipsToBounds = true
        self.ballHitForceProgressView.layer.cornerRadius = 5
        self.ballHitForceProgressView.alpha = 1
        UIView.animate(withDuration: 0.5) { self.ballHitForceProgressView.setProgress(force/10, animated: true) }
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
        case 0.5...0.83:
            interval = 0.4
        case 0.83...1.16:
            interval = 0.367
        case 1.16...1.49:
            interval = 0.334
        case 1.49...1.82:
            interval = 0.301
        case 1.82...2.15:
            interval = 0.268
        case 2.15...2.48:
            interval = 0.235
        case 2.48...2.81:
            interval = 0.202
        case 2.81...3.14:
            interval = 0.169
        case 3.14...3.47:
            interval = 0.136
        case 3.47...:
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
    
    // MARK: Ball Position At Start / Reset
    
    @IBAction func resetBallLocationButton(_ sender: Any) {
        scoreLabel.text = "0"
        gameManager.restartGame()
        resetBallToInitialLocation()
    }
    
    private func resetBallToInitialLocation() {
        globalBallNode.isHidden = false
        guard let physicsBody = globalBallNode.physicsBody else{
            return
        }
        physicsBody.velocity = SCNVector3(0, 0, 0)
        physicsBody.angularVelocity = SCNVector4(0, 0, 0, 0)
        
        //grab the game level offset
        let level = gameManager.getCurrentLevel()
        let levelNum = gameManager.currentLevelNum
        
        for node in courseNode.childNodes{
            if node.name == "tee" {
                switch levelNum {
                case 1:
                    globalBallNode.position = SCNVector3(courseNode.position.x + node.position.x * level.scale, //course1 - works!
                        courseNode.position.y,
                        courseNode.position.z + node.position.z * level.scale)
                case 2:
                    globalBallNode.position = SCNVector3(courseNode.position.x + node.position.x * level.scale, //course2 - works!
                        courseNode.position.y + 0.2,
                        courseNode.position.z + node.position.z * level.scale)
                case 3:
                    globalBallNode.position = SCNVector3(courseNode.position.x + node.position.x * level.scale, //course3 -works!
                        courseNode.position.y + 0.07,
                        courseNode.position.z - node.position.z * level.scale)
                default:
                    print("We have no level 4")
                }
            }
        }
    }
    
    // MARK: Penalty Stroke / Victory Page
    
    private func penaltyStroke(){
        DispatchQueue.main.async {
            self.messageLabel.text = "Penalty stroke"
        }
        resetBallToInitialLocation()
        normalStroke()
    }
    
    private func normalStroke(){
        gameManager.incrementShotCount()
        DispatchQueue.main.async {
            self.scoreLabel.text = self.gameManager.getCurrentPlayerScore().description
        }
    }
    
    private func checkAndShowVictoryScreen(){
        guard let physicsBody = globalBallNode.physicsBody else{
            return
        }
        print ("Velocity is \(physicsBody.velocity)")
        //Make sure the ball is slow enough
        let velocityMargin = SCNVector3(0.2, 0.2, 0.2)
        if abs(physicsBody.velocity.x) < velocityMargin.x &&
            abs(physicsBody.velocity.y) < velocityMargin.y &&
            abs(physicsBody.velocity.z) < velocityMargin.z
        {
            DispatchQueue.main.async {
                let ballInHoleSound =  self.sounds["ballInHole"]!
                self.globalBallNode.runAction(SCNAction.playAudio(ballInHoleSound, waitForCompletion: false))
                self.globalBallNode.isHidden = true
                self.courseNode.removeAllAudioPlayers()
                
                if (self.gameManager.gameEnded())
                {
                    return
                }
                self.gameManager.endGame()
                self.performSegue(withIdentifier: "segueToVictoryScreen", sender: self)
            }
        }
    }
}

// MARK: Collison Reporting Tests

enum bodyType: Int {
    case ball = 1
    case wall = 2
    case hole = 4
    case ground = 8
    case water = 16
}
extension ViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        //ball contact with hole, hole contact with ball
        
        if contact.nodeA.physicsBody?.categoryBitMask == bodyType.ball.rawValue &&
            contact.nodeB.physicsBody?.categoryBitMask == bodyType.hole.rawValue {
            print("collison between ball and hole")
            checkAndShowVictoryScreen()
        }
        else if contact.nodeB.physicsBody?.categoryBitMask == bodyType.ball.rawValue &&
            contact.nodeA.physicsBody?.categoryBitMask == bodyType.hole.rawValue {
            print("collison between hole and ball")
            checkAndShowVictoryScreen()
        }
        
        //ball contact with water, water contact with ball
        
        if contact.nodeA.physicsBody?.categoryBitMask == bodyType.ball.rawValue &&
            contact.nodeB.physicsBody?.categoryBitMask == bodyType.water.rawValue {
            print("collison between ball and water")
            penaltyStroke()
        }
        else if contact.nodeB.physicsBody?.categoryBitMask == bodyType.ball.rawValue &&
            contact.nodeA.physicsBody?.categoryBitMask == bodyType.water.rawValue {
            print("collison between water and ball")
            penaltyStroke()
        }
    }
}

// MARK: Victory ViewController

extension ViewController: VictoryViewControllerDelegate{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToVictoryScreen"{
            guard let controller = segue.destination as? VictoryViewController else
            {
                return
            }
            controller.delegate = self
            controller.score = gameManager.getCurrentPlayerScore()
        }
    }
    
    func advanceToNextLevel(){
        print("Advance to next level")
        gameManager.advanceLevel()
        let oldPosition = courseNode.position
        let oldTransform = courseNode.transform
        addCourseAtPosition(oldPosition, oldTransform)
        resetBallToInitialLocation()
        scoreLabel.text = "0"
        loadBackgroundMusic()
        gameManager.startGame()
    }
    
    func returnToMainMenu(){
        print("quit game")
        gameManager.endGame()
        sceneView.session.pause()

        courseNode.removeAllAudioPlayers()
        self.dismiss(animated: true) {
        }
    }
}
