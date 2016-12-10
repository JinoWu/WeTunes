//
//  GusetViewController.swift
//  WeTunesProtp
//
//  Created by Jino Wu on 10/14/16.
//  Copyright © 2016 Jino Wu. All rights reserved.
//

import UIKit

class GusetViewController: UIViewController {

    @IBAction func joinButton(_ sender: Any) {
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.navigationItem.title = "Scanning Holders"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "guestSegue") {
            let svc = segue.destination as! MusicPlayerViewController;
            svc.isGuest = true;
        }
    }
}
