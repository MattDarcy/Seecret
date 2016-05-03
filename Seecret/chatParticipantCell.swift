//
//  chatParticipantCell.swift
//  Seecret
//
//  Created by Matt D'Arcy on 10/28/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//


/***********************************************************************************************
//MARK: TODO
***********************************************************************************************/


import UIKit

class chatParticipantCell: UITableViewCell {
    

    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
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

