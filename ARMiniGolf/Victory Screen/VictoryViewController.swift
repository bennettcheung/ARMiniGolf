//
//  VictoryViewController.swift
//  ARMiniGolf
//
//  Created by Bennett on 2018-09-29.
//  Copyright © 2018 iNomad Studio. All rights reserved.
//

import UIKit
import AVFoundation

protocol VictoryViewControllerDelegate {
  func advanceToNextLevel()
}

class VictoryViewController: UIViewController {
  var backgroundMusicPlayer: AVAudioPlayer?
  var score: Int = 0
  var delegate: VictoryViewControllerDelegate?
  @IBOutlet weak var nextHoleButton: UIButton!
  @IBOutlet weak var scoreLabel: UILabel!
  
  
  override func viewDidLoad() {
        super.viewDidLoad()
        nextHoleButton.layer.cornerRadius = 10

      //start playing background music
        if let path = Bundle.main.path(forResource: "victory.mp3", ofType:nil){
          let url = URL(fileURLWithPath: path)
          do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.volume = 0.4
            backgroundMusicPlayer?.play()
            
          } catch {
            print(" couldn't load file ")
          }
        }
      scoreLabel.text = score.description
    }
    
  @IBAction func nextHoldPressed(_ sender: Any) {
    
    backgroundMusicPlayer?.stop()
    if let delegate = delegate{
      delegate.advanceToNextLevel()
    }
    self.dismiss(animated: true) {
      self.delegate = nil
    }
  }
  

}
