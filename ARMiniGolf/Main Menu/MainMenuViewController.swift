//
//  MainMenuViewController.swift
//  ARMiniGolf
//
//  Created by Bennett on 2018-09-23.
//  Copyright © 2018 iNomad Studio. All rights reserved.
//

import UIKit
import AVFoundation

class MainMenuViewController: UIViewController {
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var backgroundMusicPlayer: AVAudioPlayer?
    
    @IBOutlet weak var hole1Button: UIButton!
    @IBOutlet weak var hole2Button: UIButton!
    @IBOutlet weak var hole3Button: UIButton!
    
    @IBOutlet weak var hole1CenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var hole2CenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var hole3CenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startGameButton: UIButton!
  
  override func viewDidLoad() {
        super.viewDidLoad()
    
    //start playing background music
    let path = Bundle.main.path(forResource: "mainmenu.mp3", ofType:nil)!
    let url = URL(fileURLWithPath: path)
    do {
      backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
      backgroundMusicPlayer?.volume = 0.4
      backgroundMusicPlayer?.play()
    } catch {
      print(" couldn't load file ")
    }

    // Setup the level selection buttons
    
    hole1Button.layer.borderColor = UIColor.white.cgColor
    hole1Button.layer.borderWidth = 1.5
    hole1Button.layer.cornerRadius = 20
    hole1Button.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
    hole2Button.layer.borderColor = UIColor.white.cgColor
    hole2Button.layer.borderWidth = 1.5
    hole2Button.layer.cornerRadius = 20
     hole2Button.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
    hole3Button.layer.borderColor = UIColor.white.cgColor
    hole3Button.layer.borderWidth = 1.5
    hole3Button.layer.cornerRadius = 20
     hole3Button.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
    
    //animate the selection buttons in from the side
    
    DispatchQueue.main.async {[unowned self] in
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, animations: {
            self.hole1CenterXConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
        UIView.animate(withDuration: 1.5, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, animations: {
            self.hole2CenterXConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
        UIView.animate(withDuration: 1.5, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, animations: {
            self.hole3CenterXConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    }
    

  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard let controller = segue.destination as? ViewController else{
            return
        }
      
      backgroundMusicPlayer?.stop()
      
      if segue.identifier == "hole1Button"{
            controller.setLevel(1)
        }
        if segue.identifier == "hole2Button"{
            controller.setLevel(2)
        }
        if segue.identifier == "hole3Button"{
            controller.setLevel(3)
        }
    }
 

}
