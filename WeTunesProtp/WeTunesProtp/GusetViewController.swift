//
//  GusetViewController.swift
//  WeTunesProtp
//
//  Created by Jino Wu on 10/14/16.
//  Copyright © 2016 Jino Wu. All rights reserved.
//

import UIKit

class GusetViewController: UIViewController, UITableViewDataSource, UITabBarDelegate {



    @IBOutlet weak var tableView: UITableView!
    
    var name = ["Siddharth's Iphone","Jino's Ipad"]
    var model = ["Iphone 7","Ipad Pro"]
    var images = [UIImage(named: "iPhone_000000_100"),UIImage(named: "iPad_000000_100")]
    
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
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return name.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        
        
        cell.photo.image = images[indexPath.row]
        cell.name.text = name[indexPath.row]
        cell.modelName.text = model[indexPath.row]
        
        return cell
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
            let nextViewController = segue.destination as! MusicPlayerViewController;
            nextViewController.isGuest = true;
            nextViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        }
    }
}
