//
//  MusicPlayerViewController.swift
//  WeTunesProtp
//
//  Created by Jino Wu on 10/14/16.
//  Copyright © 2016 Jino Wu. All rights reserved.
//

import UIKit

class MusicPlayerViewController: UIViewController {

    @IBAction func Disconnect(_ sender: AnyObject) {
        // go back to the previous view controller
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "My Heart Will Go On"
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

}
