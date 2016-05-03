//
//  chatsCell.swift
//  Seecret
//
//  Created by Matt D'Arcy on 8/27/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//

/***********************************************************************************************
//MARK: TODO
***********************************************************************************************/


import UIKit

class chatsCell: UITableViewCell {
    
    @IBOutlet weak var chatNameLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var multQty: UILabel!
    @IBOutlet weak var multIcon: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var lastMsgTimeStamp: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
/***********************************************************************************************
//MARK: Make profile image a circle
***********************************************************************************************/
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        
/***********************************************************************************************
//MARK: Initially hide multiple participant icon and label
***********************************************************************************************/
        multIcon.hidden = true
        multQty.text = ""
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}

/***********************************************************************************************
//MARK: CODE CLOSET
***********************************************************************************************/

