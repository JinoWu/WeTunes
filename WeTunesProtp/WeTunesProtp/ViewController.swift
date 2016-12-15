//
//  ViewController.swift
//  WeTunesProtp
//
//  Created by Jino Wu on 10/14/16.
//  Copyright © 2016 Jino Wu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var hostMode: UIButton!

    @IBOutlet weak var clientMode: UIButton!
    
    @IBAction func helpButton(_ sender: Any) {
        // open an Youtube Video as tutorial
        let url = URL(string : "https://youtu.be/QoKoeLOIsqY")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:])
        } else {
            // show alert of "no network" or "video is not available"
            let alert = UIAlertController(title: "Cannot open tutorial", message: "Network is not accessible.", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        hostMode.layer.cornerRadius = 10
        clientMode.layer.cornerRadius = 10
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "hostSegue") {
            let nextViewController = segue.destination as! MusicPlayerViewController;
            nextViewController.isHost = true;
            nextViewController.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        }
        if (segue.identifier == "joinOthersSegue") {
            let nextViewController = segue.destination
                // typo here. "Guest" instead of "Guset"
                as! GusetViewController;
            nextViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        }
    }

}

 
