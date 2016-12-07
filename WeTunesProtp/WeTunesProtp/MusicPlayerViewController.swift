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

class MusicPlayerViewController: UIViewController {
	// MARK: - Variables
	var myMusicPlayer = AVAudioPlayer()
	var playerPrepared = false
	let musicService = MusicServiceManager()
	var song:AVAsset? = nil
	var songItem:MPMediaItem? = nil
	var isHolderMode = false
	var timer = Timer()
	var trackElapsed:TimeInterval!
	var isSliderTouching = false
	@IBOutlet var imageAlbum: UIImageView!
	@IBOutlet weak var labelTrackArtistAlbum: UILabel!
	@IBOutlet weak var labelElapsed: UILabel!
	@IBOutlet weak var labelRemaining: UILabel!
	@IBOutlet weak var labelNumberOfDevicesConnected: UILabel!
	@IBOutlet var sliderTime: UISlider!
	@IBAction func sliderTimeChanged(_ sender: Any) {
//		mp.currentPlaybackTime = TimeInterval(sliderTime.value)
		myMusicPlayer.currentTime = TimeInterval(sliderTime.value)
		isSliderTouching = false
	}
	@IBAction func sliderTimeTouchDown(_ sender: Any) {
		isSliderTouching = true
	}
    @IBAction func Disconnect(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
		if playerPrepared {
			myMusicPlayer.stop()
		}
		musicService.disconnect()
    }
    @IBOutlet weak var playOrPauseOutLet: UIButton!
    @IBAction func playOrPause(_ sender: Any) {
		if playerPrepared {
			if myMusicPlayer.isPlaying{
				myMusicPlayer.pause()
				playOrPauseOutLet.setBackgroundImage(UIImage(named:"Play"), for: UIControlState.normal)
			}else{
				myMusicPlayer.play()
				playOrPauseOutLet.setBackgroundImage(UIImage(named:"Pause"), for: UIControlState.normal)
			}
		}
    }
	@IBAction func buttonPrevious(_ sender: Any) {
//		if trackElapsed < 3 {
//			mp.skipToPreviousItem()
//		} else {
//			mp.skipToBeginning()
//		}
	}
	@IBAction func buttonNext(_ sender: Any) {
//		mp.skipToNextItem()
	}
	// MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
		musicService.delegate = self
//		mp.setQueue(with: selectedSongs)
//		mp.prepareToPlay()
		timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
		timer.tolerance = 0.1
//		mp.beginGeneratingPlaybackNotifications()
//		NotificationCenter.default.addObserver(self, selector: #selector(updateNowPlayingInfo), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
		
		
		imageAlbum.layer.shadowColor = UIColor.darkGray.cgColor
		imageAlbum.layer.shadowOffset = CGSize.zero
		imageAlbum.layer.shadowOpacity = 0.8;
		imageAlbum.layer.shadowRadius = 15.0;
		imageAlbum.clipsToBounds = false;
		if playerPrepared {
			if myMusicPlayer.isPlaying{
				playOrPauseOutLet.setBackgroundImage(UIImage(named:"Pause"), for: UIControlState.normal)
			}else{
				playOrPauseOutLet.setBackgroundImage(UIImage(named:"Play"), for: UIControlState.normal)
			}
		} else {
			playOrPauseOutLet.setBackgroundImage(UIImage(named:"Play"), for: UIControlState.normal)
		}
		
    }
	func timerFired() {
		if let music = song,playerPrepared{
//			print(music.tracks.count)
			let metadata = music.metadata(forFormat: AVMetadataFormatID3Metadata)
			var title:String?
			var trackArtist:String?
			var trackAlbum:String?
			var artwork:UIImage?
			for item in metadata {
				if item.commonKey == "title" {
					title = item.stringValue
				}
				if item.commonKey == "artist" {
					trackArtist = item.stringValue
				}
				if item.commonKey == "albumName" {
					trackAlbum = item.stringValue
				}
				if item.commonKey == "artwork" {
					if let data = item.dataValue {
						artwork = UIImage(data: data)
					}
				}
			}
			navigationItem.title = title
			if let artist = trackArtist,let album = trackAlbum {
				labelTrackArtistAlbum.text = "\(artist) - \(album)"
			}
			imageAlbum.image = artwork
			
			let trackDuration = myMusicPlayer.duration
			let trackElapsed = myMusicPlayer.currentTime
			let trackRemaining = Int(trackDuration) - Int(trackElapsed)
			let trackElapsedMinutes = Int(trackElapsed / 60)
			let trackElapsedSeconds = Int(trackElapsed.truncatingRemainder(dividingBy: 60))
			if trackElapsedSeconds < 10 {
				labelElapsed.text = "\(trackElapsedMinutes):0\(trackElapsedSeconds)"
			} else {
				labelElapsed.text = "\(trackElapsedMinutes):\(trackElapsedSeconds)"
			}
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
	@IBAction func SelectMusicToMusicPlayerViewController(segue:UIStoryboardSegue) {
		if let songPickerViewController = segue.source as? SongPickerTableViewController,
			let songIndex = songPickerViewController.selectedSongIndex {
			self.songItem = songPickerViewController.songItems[songIndex]
			self.song=AVAsset(url: self.songItem!.assetURL!)
			
			do{
				myMusicPlayer = try AVAudioPlayer(contentsOf: self.songItem!.assetURL!, fileTypeHint: AVFileTypeAppleM4A)
				myMusicPlayer.prepareToPlay()
				self.playerPrepared=true
				let myAudioSession = AVAudioSession.sharedInstance()
				try myAudioSession.setCategory(AVAudioSessionCategoryPlayback)
				musicService.sendMediaItem(item: self.songItem!)
			}catch let error {
				print(error)
			}
			
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

extension MusicPlayerViewController: MusicServiceManagerDelegate {
	func connectedDevicesChanged(manager: MusicServiceManager, connectedDevices: [String]) {
		OperationQueue.main.addOperation { () -> Void in
			self.labelNumberOfDevicesConnected.text = "\(connectedDevices.count) devices connected"
		}
		
	}
	func dataChanged(manager: MusicServiceManager, data: Data) {
		do{
//            myMusicPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "15", ofType: "mp3")!))
			self.song = musicService.convertDataToAVAsset(data: data)!.0
			let songurl = musicService.convertDataToAVAsset(data: data)!.1
			myMusicPlayer = try AVAudioPlayer(contentsOf: songurl, fileTypeHint: AVFileTypeAppleM4A)
			myMusicPlayer.prepareToPlay()
			self.playerPrepared=true
			let myAudioSession = AVAudioSession.sharedInstance()
			try myAudioSession.setCategory(AVAudioSessionCategoryPlayback)
		}catch let error {
			print(error)
		}
	}
	func streamChanged(manager: MusicServiceManager, _ aStream: Stream, handle eventCode: Stream.Event) {
		
	}
}






