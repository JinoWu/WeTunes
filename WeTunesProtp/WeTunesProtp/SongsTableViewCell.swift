//
//  SongsTableViewCell.swift
//  WeTunesProtp
//
//  Created by Stefan Lin on 11/11/16.
//  Copyright © 2016 Jino Wu. All rights reserved.
//

import UIKit

class SongsTableViewCell: UITableViewCell {
	@IBOutlet weak var trackName: UILabel!
	@IBOutlet weak var imageAlbum: UIImageView!
	@IBOutlet weak var trackArtist: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
