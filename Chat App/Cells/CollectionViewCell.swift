//
//  CollectionViewCell.swift
//  Chat App
//
//  Created by Mohamed Mahmoud Zaki on 10/31/18.
//  Copyright © 2018 Mohamed Mahmoud Zaki. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var txtLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var labelTrailing: NSLayoutConstraint!
    @IBOutlet weak var labelLeading: NSLayoutConstraint!
    @IBOutlet weak var labelWidth: NSLayoutConstraint!
    @IBOutlet weak var chatImage: UIImageView!
}
