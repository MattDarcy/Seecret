//
//  firstNavConVC.swift
//  Seecret
//
//  Created by Matt D'Arcy on 10/21/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//

/***********************************************************************************************
//MARK: TODO
***********************************************************************************************/
// Have the login-skip routine collect the active tab the user was on when last exiting the app and then segue to that particular tab on app resume


import UIKit
import Parse

class firstNavConVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /***********************************************************************************************
        //MARK: Skip login/signup screen if the user is already logged in
        ***********************************************************************************************/
        if (PFUser.currentUser() != nil) {
            //print("Already logged in....going to tabs")
            
            self.performSegueWithIdentifier("skipLogin", sender: self)
        } else if (PFUser.currentUser() == nil) {
            //print("Not yet logged in")
            self.performSegueWithIdentifier("needLoginSession", sender: self)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

/***********************************************************************************************
//MARK: CODE CLOSET
***********************************************************************************************/
