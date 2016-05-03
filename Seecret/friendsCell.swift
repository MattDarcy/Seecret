//
//  friendsCell.swift
//  Seecret
//
//  Created by Matt D'Arcy on 8/14/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//


/***********************************************************************************************
//MARK: TODO
***********************************************************************************************/


import UIKit
import CoreData

class friendsCell: UITableViewCell {
    
    
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    
    
    override func awakeFromNib() {
       super.awakeFromNib()
/***********************************************************************************************
//MARK: Make profile image a circle
***********************************************************************************************/
        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        profileImg.clipsToBounds = true
    }
    
override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


/***********************************************************************************************
//MARK: CODE CLOSET
***********************************************************************************************/

