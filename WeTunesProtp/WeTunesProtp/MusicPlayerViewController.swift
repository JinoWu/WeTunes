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

class MusicPlayerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Activity Indicator declare
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    // List of devide to show on connected device tableView
    var dName = [String]()
    
    // MARK: - Flags
    var isHost = false
    var isGuest = false
    @IBOutlet weak var flagLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var devicesButton: UIButton!
    @IBAction func devicesButton(_ sender: Any) {
    }
    
    @IBAction func connectedDevices(_ sender: Any) {
        if(tableView.isHidden == true) {
            tableView.isHidden = false
        } else{
            tableView.isHidden = true
        }
    }
    
    
	// MARK: - Variables
	var myMusicPlayer = AVAudioPlayer()
	var playerPrepared = false
	let musicService = MusicServiceManager.sharedInstance
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
        
		if playerPrepared {
			myMusicPlayer.stop()
		}
		musicService.disconnect()
        
        if isHost {
            // may need to kill the session
            
            performSegue(withIdentifier: "hostDisconnect", sender: self)
        } else if isGuest{
            performSegue(withIdentifier: "guestDisconnect", sender: self)
        }
    }
    
    // function to chnage play pause button image
    func btnImage(name: String){
        playOrPauseOutLet.isEnabled = false
        playOrPauseOutLet.setBackgroundImage(UIImage(named:name), for: UIControlState.normal)
        playOrPauseOutLet.isEnabled = true
        
    }
    
    @IBOutlet weak var playOrPauseOutLet: UIButton!
    @IBAction func playOrPause(_ sender: Any) {
		if playerPrepared {
			if myMusicPlayer.isPlaying{
//                playOrPauseOutLet.setBackgroundImage(UIImage(named:"Play"), for: UIControlState.normal)
				musicService.sendState(state: "pause")
				myMusicPlayer.pause()
                btnImage(name: "Play")
			}else{
//                playOrPauseOutLet.setBackgroundImage(UIImage(named:"Adervising"), for: UIControlState.normal)
				musicService.sendState(state: "play")
				myMusicPlayer.play()
                btnImage(name: "Pause")
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
    
    
    //TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dName.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "dCell", for: indexPath) as!  DeviceCell
        
        cell.deviceName.text = dName[indexPath.row]
        
        return cell
    }
    
	// MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissView")
        
        view.addGestureRecognizer(tap)
        
        // hide tableview on ONLOAD
        tableView.isHidden = true
        tableView.allowsSelection = false
        tableView.layer.cornerRadius = 10
        tableView.layer.opacity = 0.9
    
		musicService.delegate = self
        if (self.isHost) {
            self.flagLabel.text = "This is a host !"
        } else {
            self.flagLabel.text = "This is a guest !"
        }
        self.devicesButton.setBackgroundImage(
            UIImage(named:"Adervising")?.withRenderingMode(.alwaysOriginal), for: .normal)
//		mp.setQueue(with: selectedSongs)
//		mp.prepareToPlay()
		timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
		timer.tolerance = 0.1
//		mp.beginGeneratingPlaybackNotifications()
//		NotificationCenter.default.addObserver(self, selector: #selector(updateNowPlayingInfo), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
		
		
		imageAlbum.layer.shadowColor = UIColor.darkGray.cgColor
		imageAlbum.layer.shadowOffset = CGSize.init(width: 2, height: 2)
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
        
        // start animating ActivityIndicator
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
       
        
    }
    
    func dismissView() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        tableView.isHidden = true
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
		self.isHolderMode=true
		musicService.transferingStatus.removeAll()
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
                

                
                // activityIndicator to start animating
                DispatchQueue.main.async{
                    self.activityIndicator.startAnimating()
                    self.flagLabel.text = "Sending music file ...."
                    UIApplication.shared.beginIgnoringInteractionEvents()
                }
                print("start animating")
                
			}catch let error {
				print(error)
			}
			
		}
	}
	
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "hostDisconnect") {
            let nextViewController = segue.destination as! ViewController;
            nextViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        }
        if (segue.identifier == "guestDisconnect") {
            let nextViewController = segue.destination
                // typo here. "Guest" instead of "Guset"
                as! GusetViewController;
            nextViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        }
        
    }
    
}

extension MusicPlayerViewController: MusicServiceManagerDelegate {
	func connectedDevicesChanged(manager: MusicServiceManager, connectedDevices: [String]) {
        
		OperationQueue.main.addOperation { () -> Void in
            let connectedDevicesNum = self.musicService.session.connectedPeers.count
			self.labelNumberOfDevicesConnected.text = "\(connectedDevicesNum)"
            if connectedDevicesNum <= 0 {
                self.devicesButton.setBackgroundImage(
                    UIImage(named:"Adervising")?.withRenderingMode(.alwaysOriginal), for: .normal)
            } else{
                self.devicesButton.setBackgroundImage(
                    UIImage(named:"Two Smartphones")?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
		}
        DispatchQueue.main.async{
            self.dName = connectedDevices
            self.tableView.reloadData()
        }

		
	}
	func dataChanged(manager: MusicServiceManager, data: Data) {
		isHolderMode=false
		do{
            // activityIndicator to start animating
            DispatchQueue.main.async{
                self.activityIndicator.startAnimating()
                self.flagLabel.text = "Receiving music file ...."
                UIApplication.shared.beginIgnoringInteractionEvents()
            }
            print("start animating")
            
            
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
		musicService.sendState(state: "ready")
	}
	func stateReceived(manager: MusicServiceManager, state: String) {
        
        
		if state == "ready" && isHolderMode && musicService.transferingStatus.count == musicService.session.connectedPeers.count{
			musicService.sendState(state: "play")
			self.myMusicPlayer.play()

            DispatchQueue.main.async{
                self.btnImage(name: "Pause")
            }
		}
		if state == "play" && playerPrepared{
			self.myMusicPlayer.play()
            DispatchQueue.main.async{
                self.btnImage(name: "Pause")
            }
		}
		if state == "pause" && playerPrepared{
			self.myMusicPlayer.pause()
            DispatchQueue.main.async{
                self.btnImage(name: "Play")
            }
		}
        
        // activityIndicator to stop animating
        DispatchQueue.main.async{
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            self.flagLabel.text = ""
        }
        
	}
	func streamChanged(manager: MusicServiceManager, _ aStream: Stream, handle eventCode: Stream.Event) {
		
	}
}






