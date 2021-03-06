//
//  CustomCellTableViewCell.swift
//  QiitaApp
//
//  Created by Junki Takada on 2016/09/21.
//  Copyright © 2016年 Junki Takada. All rights reserved.
//

import UIKit

class CustomCellTableViewCell: UITableViewCell {

    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleUserIdLabel: UILabel!
    
    // 記事ページのURL
    var articleUrl: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        //再利用時に元々入っている情報をクリア
        articleImageView.image = nil
    }
}
