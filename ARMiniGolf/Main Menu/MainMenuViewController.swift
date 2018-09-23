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
  
  @IBOutlet weak var startGameButton: UIButton!
  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    startGameButton.clipsToBounds = true
    startGameButton.layer.cornerRadius = 10.0
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
