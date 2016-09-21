//
//  FavoriteArticleTableViewCell.swift
//  QiitaApp
//
//  Created by Junki Takada on 2016/09/16.
//  Copyright © 2016年 Junki Takada. All rights reserved.
//

import UIKit

class FavoriteArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var favoriteArticleThumbnailView: UIImageView!
    @IBOutlet weak var favoriteArticleTitleLabel: UILabel!
    @IBOutlet weak var favoriteArticleUserIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
