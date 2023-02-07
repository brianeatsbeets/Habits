//
//  FollowedUserCollectionViewCell.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 2/1/23.
//

import UIKit

class FollowedUserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var primaryTextLabel: UILabel!
    @IBOutlet var secondaryTextLabel: UILabel!
    @IBOutlet var separatorLineView: UIView!
    @IBOutlet var separatorLineHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        
        // Set the height to 1 pixel regardless of device pixel density
        separatorLineHeightConstraint.constant = 1 / UITraitCollection.current.displayScale
    }
    
}
