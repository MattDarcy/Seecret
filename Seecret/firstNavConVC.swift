/*
firstNavConVC.swift
Seecret
Created by Matt D'Arcy on 10/21/15.
Copyright (c) 2015 Seecret. All rights reserved.
*/

import UIKit
import Parse

class firstNavConVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Skip login/signup screen if the user is already logged in
        if (PFUser.currentUser() != nil)
        {
            self.performSegueWithIdentifier("skipLogin", sender: self)
        }
        else if (PFUser.currentUser() == nil)
        {
            self.performSegueWithIdentifier("needLoginSession", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}