//
//  MusicPlayerViewController.swift
//  WeTunesProtp
//
//  Created by Jino Wu on 10/14/16.
//  Copyright © 2016 Jino Wu. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MusicPlayerViewController: UIViewController {
//	var myMusicPlayer = AVAudioPlayer()
	let mp = MPMusicPlayerController.systemMusicPlayer()
	var timer = Timer()
	@IBOutlet var imageAlbum: UIImageView!
	@IBOutlet weak var labelTrackArtistAlbum: UILabel!
	@IBOutlet weak var labelElapsed: UILabel!
	@IBOutlet weak var labelRemaining: UILabel!
	var trackElapsed:TimeInterval!
	var selectedSongs: MPMediaItemCollection!
//	var songs = [MPMediaItem]()
	
	
    @IBAction func Disconnect(_ sender: AnyObject) {
        // go back to the previous view controller
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBOutlet weak var playOrPauseOutLet: UIButton!
    @IBAction func playOrPause(_ sender: Any) {
		if mp.playbackState == .paused || mp.playbackState == .stopped {
			mp.play()
			playOrPauseOutLet.setBackgroundImage(UIImage(named:"Pause"), for: UIControlState.normal)
		} else if mp.playbackState == .playing {
			mp.pause()
			playOrPauseOutLet.setBackgroundImage(UIImage(named:"Play"), for: UIControlState.normal)
		}
//        if myMusicPlayer.isPlaying{
//            myMusicPlayer.pause()
//            playOrPauseOutLet.setBackgroundImage(UIImage(named:"Play"), for: UIControlState.normal)
//        }else{
//            myMusicPlayer.play()
//            playOrPauseOutLet.setBackgroundImage(UIImage(named:"Pause"), for: UIControlState.normal)
//        }
    }
	@IBAction func buttonPrevious(_ sender: Any) {
		if trackElapsed < 3 {
			mp.skipToPreviousItem()
		} else {
			mp.skipToBeginning()
		}
	}
	@IBAction func buttonNext(_ sender: Any) {
		mp.skipToNextItem()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		if selectedSongs != nil {
			mp.setQueue(with: selectedSongs)
			mp.prepareToPlay()
			timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
			timer.tolerance = 0.1
			mp.beginGeneratingPlaybackNotifications()
			NotificationCenter.default.addObserver(self, selector: #selector(updateNowPlayingInfo), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
		}
		
		
		
		

		
        playOrPauseOutLet.setBackgroundImage(UIImage(named:"Play"), for: UIControlState.normal)
        
        
//        do{
//            myMusicPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "15", ofType: "mp3")!))
//            myMusicPlayer.prepareToPlay()
//            
//            var myAudioSession = AVAudioSession.sharedInstance()
//            do{
//                try myAudioSession.setCategory(AVAudioSessionCategoryPlayback)
//            }catch{
//                print(error)
//            }
//        }catch{
//            print(error)
//        }
    }
	func timerFired() {
		if let currentTrack = MPMusicPlayerController.systemMusicPlayer().nowPlayingItem {
			navigationItem.title = currentTrack.title!
			let trackArtist = currentTrack.artist!
			let trackAlbum = currentTrack.albumTitle!
			labelTrackArtistAlbum.text = "\(trackArtist) - \(trackAlbum)"
			imageAlbum.image = currentTrack.artwork?.image(at: imageAlbum.bounds.size)
			let trackDuration = currentTrack.playbackDuration
			trackElapsed = mp.currentPlaybackTime
			let trackElapsedMinutes = Int(trackElapsed / 60)
			let trackElapsedSeconds = Int(trackElapsed.truncatingRemainder(dividingBy: 60))
			if trackElapsedSeconds < 10 {
				labelElapsed.text = "\(trackElapsedMinutes):0\(trackElapsedSeconds)"
			} else {
				labelElapsed.text = "\(trackElapsedMinutes):\(trackElapsedSeconds)"
			}
			let trackRemaining = Int(trackDuration) - Int(trackElapsed)
			let trackRemainingMinutes = trackRemaining / 60
			let trackRemainingSeconds = trackRemaining % 60
			if trackRemainingSeconds < 10 {
				labelRemaining.text = "Remaining: \(trackRemainingMinutes):0\(trackRemainingSeconds)"
			} else {
				labelRemaining.text = "Remaining: \(trackRemainingMinutes):\(trackRemainingSeconds)"
			}
		}
	}
	func updateNowPlayingInfo(){
		timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
		timer.tolerance = 0.1
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
