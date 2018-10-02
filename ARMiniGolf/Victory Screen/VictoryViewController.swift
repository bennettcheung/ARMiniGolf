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
  func returnToMainMenu()
}


class VictoryViewController: UIViewController {
  var backgroundMusicPlayer: AVAudioPlayer?
  var score: Int = 0
  var delegate: VictoryViewControllerDelegate?

  @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var nextHoleButton: UIButton!
    @IBOutlet weak var quitGameButton: UIButton!
    
    @IBOutlet weak var nextHoleCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var quitGameCenterXConstraint: NSLayoutConstraint!
    
    
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
    
    quitGameButton.layer.borderColor = UIColor.white.cgColor
    quitGameButton.layer.borderWidth = 1.5
    quitGameButton.layer.cornerRadius = 20
    quitGameButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
    nextHoleButton.layer.borderColor = UIColor.white.cgColor
    nextHoleButton.layer.borderWidth = 1.5
    nextHoleButton.layer.cornerRadius = 20
    nextHoleButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
   
    
    //animate the selection buttons in from the side
    
    DispatchQueue.main.async {[unowned self] in
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, animations: {
            self.nextHoleCenterXConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
        UIView.animate(withDuration: 1.5, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, animations: {
            self.quitGameCenterXConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    }
    
  @IBAction func nextHolePressed(_ sender: Any) {
    
    backgroundMusicPlayer?.stop()
    if let delegate = delegate{
      delegate.advanceToNextLevel()
    }
    self.dismiss(animated: true) {
      self.delegate = nil
    }
  }
    
    @IBAction func quitGamePressed(_ sender: Any) {
        
        backgroundMusicPlayer?.stop()

        self.dismiss(animated: true) {
            self.delegate = nil
            if let delegate = self.delegate{
                delegate.returnToMainMenu()
            }
        }
    }
  

}
