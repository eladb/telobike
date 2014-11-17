//
//  TBSearchResultTableViewCell.swift
//  telobike
//
//  Created by Elad Ben-Israel on 11/16/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

import Foundation

class TBSearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var resultTitleLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    
    var icon: UIImage? {
        didSet {
            self.iconView.image = icon
        }
    }

    var title: String? {
        didSet {
            self.resultTitleLabel.text = self.title
        }
    }
    
    var detail: String? {
        didSet {
            self.distanceLabel.text = self.detail
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.iconView.image = nil
        self.resultTitleLabel.text = nil
        self.distanceLabel.text = nil
    }
}
