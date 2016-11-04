//
//  MusicPlayerViewController.swift
//  WeTunesProtp
//
//  Created by Jino Wu on 10/14/16.
//  Copyright © 2016 Jino Wu. All rights reserved.
//

import UIKit
import AVFoundation
class MusicPlayerViewController: UIViewController {

    @IBAction func Disconnect(_ sender: AnyObject) {
        // go back to the previous view controller
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBOutlet weak var playOrPauseOutLet: UIButton!
    @IBAction func playOrPause(_ sender: Any) {
        if myMusicPlayer.isPlaying{
            myMusicPlayer.pause()
            playOrPauseOutLet.setBackgroundImage(UIImage(named:"Play"), for: UIControlState.normal)
        }else{
            myMusicPlayer.play()
            playOrPauseOutLet.setBackgroundImage(UIImage(named:"Pause"), for: UIControlState.normal)
        }
    }
    
    
    var myMusicPlayer = AVAudioPlayer()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "My Heart Will Go On"
        playOrPauseOutLet.setBackgroundImage(UIImage(named:"Play"), for: UIControlState.normal)
        
        
        do{
            myMusicPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "15", ofType: "mp3")!))
            myMusicPlayer.prepareToPlay()
            
            var myAudioSession = AVAudioSession.sharedInstance()
            do{
                try myAudioSession.setCategory(AVAudioSessionCategoryPlayback)
            }catch{
                print(error)
            }
        }catch{
            print(error)
        }
        
        
        
        
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
