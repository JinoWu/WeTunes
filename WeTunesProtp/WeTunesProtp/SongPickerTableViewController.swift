//
//  SongPickerTableViewController.swift
//  WeTunesProtp
//
//  Created by Stefan Lin on 11/17/16.
//  Copyright © 2016 Jino Wu. All rights reserved.
//

import UIKit
import MediaPlayer

class SongPickerTableViewController: UITableViewController {
	var songItems = [MPMediaItem]()
	var selectedSongIndex:Int? = nil
	@IBAction func CancelButtonClicked(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		loadSong()
		self.tableView.delegate = self
		self.tableView.rowHeight = 44
		self.tableView.reloadData()
		// Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
	func loadSong() {
		let query = MPMediaQuery.songs()
		query.addFilterPredicate(MPMediaPropertyPredicate.init(value: NSNumber(value: false), forProperty: MPMediaItemPropertyIsCloudItem))
		if let items = query.items {
			for item in items {
				if item.assetURL != nil {
					songItems.append(item)
				}
			}
		}
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songItems.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "song", for: indexPath) as! SongsTableViewCell
		let song = songItems[indexPath.row]
		cell.imageAlbum.image = song.artwork?.image(at: cell.imageAlbum.bounds.size)
		cell.trackName.text = song.title!
		cell.trackArtist.text = song.artist!
		//		cell.imageAlbum.layer.backgroundColor=UIColor.clear.cgColor
		//		cell.imageAlbum.layer.cornerRadius = Int(cell.imageAlbum.bounds.size) / 2
		//		cell.imageAlbum.layer.masksToBounds=true
        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		self.selectedSongIndex = indexPath.row
	}
	
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "SelectMusic" {
			if let cell = sender as? SongsTableViewCell {
				let indexPath = tableView.indexPath(for: cell)
				if let index = indexPath?.row {
					selectedSongIndex = index
				}
			}
		}
		
	}
	

}
