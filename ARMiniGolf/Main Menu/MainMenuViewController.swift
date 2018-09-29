//
//  MainMenuViewController.swift
//  ARMiniGolf
//
//  Created by Bennett on 2018-09-23.
//  Copyright © 2018 iNomad Studio. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
    @IBOutlet weak var course1CenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var course2CenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var course3CenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var course1ImageView: UIImageView!
    @IBOutlet weak var course2ImageView: UIImageView!
    @IBOutlet weak var course3ImageView: UIImageView!
    
    @IBOutlet weak var startGameButton: UIButton!
  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    startGameButton.clipsToBounds = true
    startGameButton.layer.cornerRadius = 10.0
    //remove center x contraints on all 3
    
    let movementRightOffset = view.frame.width/2 + course1ImageView.frame.width/2
      let movementLeftOffset = -1 * (view.frame.width/2 + course1ImageView.frame.width/2)
    
    course1CenterXConstraint.constant = movementRightOffset
    course2CenterXConstraint.constant = movementLeftOffset
    course3CenterXConstraint.constant = movementRightOffset
    
    UIView.animate(withDuration: 2, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, animations: {
        self.course1CenterXConstraint.constant = 0
        self.view.layoutIfNeeded()
    })
    UIView.animate(withDuration: 2, delay: 2, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, animations: {
        self.course2CenterXConstraint.constant = 0
        self.view.layoutIfNeeded()
    })
    UIView.animate(withDuration: 2, delay: 3, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, animations: {
        self.course3CenterXConstraint.constant = 0
        self.view.layoutIfNeeded()
    })
    
    //set the c1 leading to the view trailing
    
    
    //?? set the c1 trailing to the view trailing + c1.width ?? Do I need this if I have a width set?
    
  
    
    
    //set the c2 trailing to the view leading
    
    //?? set the c1 trailing to the view leading + c1.width ?? Do I need this if I have a width set?
    
    //set the c3 leading to the view trailing
    //?? set the c3 trailing to the view leading + c1.width ?? Do I need this if I have a width set?
    
    // then animate turning off the above 3 and turning on the 3 center ones
    }
    

  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
      
      if segue.identifier == "segueToGameScreen"{
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
      }
    }
 

}
