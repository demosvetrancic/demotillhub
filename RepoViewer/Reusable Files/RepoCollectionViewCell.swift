//
//  RepoCollectionViewCell.swift
//  RepoViewer
//
//  Created by Svetozar Rancic on 10/10/17.
//  Copyright © 2017 svetrancic. All rights reserved.
//

import UIKit



class RepoCollectionViewCell: UICollectionViewCell
{
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelOwnerName: UILabel!
    @IBOutlet weak var labelSize: UILabel!
    @IBOutlet weak var labelEstimatedTime: UILabel!
    
    func updateOutlets(withName repoName: String?, withOwner ownerName: String?, withSize size: String?, withEstimatedTime estimatedTime: String?, withWiki hasWiki:Bool)
    {
        self.labelName.text = repoName
        self.labelOwnerName.text = ownerName
        
        self.labelSize.text = size
        
        self.labelEstimatedTime.text = NSLocalizedString("est.time: \(estimatedTime)s", comment: "")
        
        self.backgroundColor = hasWiki ? UIColor.init(rgb:RepoCellStyle.hasWikiColor) : UIColor.init(rgb:RepoCellStyle.hasNoWikiColor)
        
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
