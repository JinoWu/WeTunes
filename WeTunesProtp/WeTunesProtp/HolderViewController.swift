//
//  HolderViewController.swift
//  WeTunesProtp
//
//  Created by Jino Wu on 10/14/16.
//  Copyright © 2016 Jino Wu. All rights reserved.
//

import UIKit
import MediaPlayer

class HolderViewController: UIViewController,MPMediaPickerControllerDelegate,UITableViewDelegate,UITableViewDataSource {
	@IBOutlet weak var tableView: UITableView!
	var selectedSongs = [MPMediaItem]()
	var mpcollection:MPMediaItemCollection!
	var mediapicker1: MPMediaPickerController!
	let mp = MPMusicPlayerController.applicationMusicPlayer()
	@IBAction func buttonAddSongs(_ sender: Any) {
		self.present(mediapicker1, animated: true, completion: nil)
	}
	
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let mediaPicker: MPMediaPickerController = MPMediaPickerController.self(mediaTypes: .music)
		mediaPicker.allowsPickingMultipleItems = true
		mediaPicker.delegate = self
		mediapicker1 = mediaPicker
		
//		self.present(mediapicker1, animated: false, completion: nil)
		
		tableView.delegate = self
		tableView.rowHeight = 44
		tableView.reloadData()
//		tableView.dataSource = self
        self.navigationItem.title = "Songs to Share"
    }
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return selectedSongs.count
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "song", for: indexPath) as! SongsTableViewCell
		let song = selectedSongs[indexPath.row]
		cell.imageAlbum.image = song.artwork?.image(at: cell.imageAlbum.bounds.size)
		cell.trackName.text = song.title!
		cell.trackArtist.text = song.artist!
//		cell.imageAlbum.layer.backgroundColor=UIColor.clear.cgColor
//		cell.imageAlbum.layer.cornerRadius = Int(cell.imageAlbum.bounds.size) / 2
//		cell.imageAlbum.layer.masksToBounds=true
		return cell
	}
	
	
	
	func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
		self.dismiss(animated: true, completion: nil)
//		tableView.reloadData()
	}
	
	private func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
		self.dismiss(animated: true, completion: nil)
		mp.setQueue(with: mediaItemCollection)
		for song in mediaItemCollection.items {
			selectedSongs.append(song)
		}
		self.mpcollection = mediaItemCollection
		self.tableView.reloadData()
//		for a in selectedSongs.items {
//			
//		}
//		mp.setQueueWithItemCollection(selectedSongs)
//		mp.play()
 }



	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "StartSharing" {
//			let vc = segue.destination as! MusicPlayerViewController
//			vc.selectedSongs = self.selectedSongs
//			for song in self.selectedSongs.items {
//				vc.songs.append(song)
//			}
		}
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
