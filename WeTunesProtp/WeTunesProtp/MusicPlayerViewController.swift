//
//  MusicPlayerViewController.swift
//  WeTunesProtp
//
//  Created by Jino Wu on 10/14/16.
//  Copyright © 2016 Jino Wu. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation
import MediaPlayer

class MusicPlayerViewController: UIViewController,MPMediaPickerControllerDelegate {
	// MARK: - Variables
//	var myMusicPlayer = AVAudioPlayer()
	let mp = MPMusicPlayerController.systemMusicPlayer()
	var timer = Timer()
	var trackElapsed:TimeInterval!
	var mediapicker1: MPMediaPickerController!
	var isSliderTouching = false
	@IBOutlet var imageAlbum: UIImageView!
	@IBOutlet weak var labelTrackArtistAlbum: UILabel!
	@IBOutlet weak var labelElapsed: UILabel!
	@IBOutlet weak var labelRemaining: UILabel!
	@IBOutlet var sliderTime: UISlider!
	@IBAction func sliderTimeChanged(_ sender: Any) {
		mp.currentPlaybackTime = TimeInterval(sliderTime.value)
		isSliderTouching = false
	}
	@IBAction func sliderTimeTouchDown(_ sender: Any) {
		isSliderTouching = true
	}
    @IBAction func Disconnect(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
	@IBAction func buttonPickMusic(_ sender: Any) {
		self.present(mediapicker1, animated: true, completion: nil)
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
	// MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
		let mediaPicker: MPMediaPickerController = MPMediaPickerController.self(mediaTypes: .music)
		mediaPicker.allowsPickingMultipleItems = true
		mediaPicker.delegate = self
		mediapicker1 = mediaPicker
		if MPMusicPlayerController.systemMusicPlayer().nowPlayingItem == nil {
			self.present(mediapicker1, animated: false, completion: nil)
		}
		
		
//		mp.setQueue(with: selectedSongs)
		mp.prepareToPlay()
		timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
		timer.tolerance = 0.1
		mp.beginGeneratingPlaybackNotifications()
		NotificationCenter.default.addObserver(self, selector: #selector(updateNowPlayingInfo), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
		
		
		imageAlbum.layer.shadowColor = UIColor.darkGray.cgColor
		imageAlbum.layer.shadowOffset = CGSize.zero
		imageAlbum.layer.shadowOpacity = 0.8;
		imageAlbum.layer.shadowRadius = 15.0;
//		imageAlbum.layer.shouldRasterize = true
//		imageAlbum.layer.shadowPath = UIBezierPath(rect: imageAlbum.bounds).cgPath
		imageAlbum.clipsToBounds = false;
//		imageAlbum.layer.cornerRadius = 10
		if mp.playbackState == .paused || mp.playbackState == .stopped {
			playOrPauseOutLet.setBackgroundImage(UIImage(named:"Play"), for: UIControlState.normal)
		} else if mp.playbackState == .playing {
			playOrPauseOutLet.setBackgroundImage(UIImage(named:"Pause"), for: UIControlState.normal)
		}
		
        
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
				labelRemaining.text = "-\(trackRemainingMinutes):0\(trackRemainingSeconds)"
			} else {
				labelRemaining.text = "-\(trackRemainingMinutes):\(trackRemainingSeconds)"
			}
			sliderTime.maximumValue = Float(trackDuration)
			if isSliderTouching == false {
				sliderTime.value = Float(trackElapsed)
			}
		}
	}
	func updateNowPlayingInfo(){
		timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
		timer.tolerance = 0.1
	}
	
	func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
		self.dismiss(animated: true, completion: nil)
		let selectedSongs = mediaItemCollection
		mp.setQueue(with: selectedSongs)
		mp.play()
		playOrPauseOutLet.setBackgroundImage(UIImage(named:"Pause"), for: UIControlState.normal)
	}
	func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
		self.dismiss(animated: true, completion: nil)
		if mp.playbackState == .paused || mp.playbackState == .stopped {
			playOrPauseOutLet.setBackgroundImage(UIImage(named:"Play"), for: UIControlState.normal)
		} else if mp.playbackState == .playing {
			playOrPauseOutLet.setBackgroundImage(UIImage(named:"Pause"), for: UIControlState.normal)
		}
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
