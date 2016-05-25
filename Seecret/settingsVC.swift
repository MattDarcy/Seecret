//
//  settingsVC.swift
//  Seecret
//
//  Created by Matt D'Arcy on 9/3/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//

/***********************************************************************************************
//MARK: TODO
***********************************************************************************************/


import UIKit

class settingsVC: UIViewController {
    
    @IBOutlet weak var logoutBtn: UIButton!

    func preTreatView() {
//only show the add button on the groups and seecrets tab
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
//show the title programatically because the tab controller negates the navigation title
        self.tabBarController?.navigationItem.title = "Settings"
        logoutBtn.layer.cornerRadius = 7
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preTreatView()
    }
    
    override func viewDidAppear(animated: Bool) {
        preTreatView()
    }



/***********************************************************************************************
//MARK: Logout
***********************************************************************************************/
    @IBAction func logoutBtn(sender: AnyObject) {
            //didLoad = false
            PFUser.logOutInBackground()
            self.performSegueWithIdentifier("logout", sender: self)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


/***********************************************************************************************
//MARK: CODE CLOSET
***********************************************************************************************/
