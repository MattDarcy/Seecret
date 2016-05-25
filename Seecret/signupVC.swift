//
//  signupVC.swift
//  Seecret
//
//  Created by Matt D'Arcy on 8/14/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//

/***********************************************************************************************
//MARK: TODO
***********************************************************************************************/
// Include code (not UIPicker) to get the user's language from a list
// Have the code check for valid birth date
// have checks for any illegal characters in parameters
// have checks for any duplicates with the server that cannot be duplicates i.e. username
// upon login of new person, nix all core data for entire app

import UIKit

class signupVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate{

    @IBOutlet var profileImg: UIImageView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var displayNameTxt: UITextField!
    @IBOutlet weak var birthMonth: UITextField!
    @IBOutlet weak var birthDay: UITextField!
    @IBOutlet weak var birthYear: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    /***********************************************************************************************
    //MARK: UIActivity Spinner
    ***********************************************************************************************/
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    func pauseApp() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,100,100))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        UIApplication.sharedApplication().keyWindow?.bringSubviewToFront(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func resumeApp() {
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    
    /***********************************************************************************************
    //MARK: Make profile image a circle, round submit button, populate language picker
    ***********************************************************************************************/
    func preTreatView() {
        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        profileImg.clipsToBounds = true
        submitBtn.layer.cornerRadius = 7
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preTreatView()
    }
    
    override func viewDidAppear(animated: Bool) {
        preTreatView()
    }
    
    /***********************************************************************************************
    //MARK: Add image button and choose from photo library
    ***********************************************************************************************/
    
    @IBAction func addImgBtn(sender: AnyObject) {
        let img = UIImagePickerController()
        img.delegate = self
        img.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        img.allowsEditing = true
        self.presentViewController(img, animated: true, completion: nil)
    }
    
    /***********************************************************************************************
    //MARK: Pick from photo library
    ***********************************************************************************************/
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        profileImg.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /***********************************************************************************************
    //MARK: Close keyboard if enter key pressed
    ***********************************************************************************************/
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailTxt.resignFirstResponder()
        usernameTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        displayNameTxt.resignFirstResponder()
        return true
    }

    /***********************************************************************************************
    //MARK: Remove keyboard when user taps blank space
    ***********************************************************************************************/
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    /***********************************************************************************************
    //MARK: Move app view up and down if keyboard would be covering a text field
    ***********************************************************************************************/
    //Moves UI view up if the keyboard would be over the field (tests screen size)
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        if (UIScreen.mainScreen().bounds.height < 5000) {
            if (textField == self.displayNameTxt){
                UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                    self.view.center = CGPointMake(theWidth/2, (theHeight/2)-40)
                    }, completion: { (finished:Bool) in
                })
            } else if (textField == self.birthMonth) || (textField == self.birthDay) || (textField == self.birthYear) {
                UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                    self.view.center = CGPointMake(theWidth/2, (theHeight/2)-40)
                    }, completion: { (finished:Bool) in
                })
            }
        }
    }
    
    //Moves UI view down if editing ends
    func textFieldDidEndEditing(textField: UITextField) {
        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        if (UIScreen.mainScreen().bounds.height < 5000) {
            if (textField == self.displayNameTxt){
                UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                    self.view.center = CGPointMake(theWidth/2, (theHeight/2))
                    }, completion: { (finished:Bool) in
                })
            } else if (textField == self.birthMonth) || (textField == self.birthDay) || (textField == self.birthYear) {
                UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                    self.view.center = CGPointMake(theWidth/2, (theHeight/2))
                    }, completion: { (finished:Bool) in
                })
            }
        }
    }
    
    
    
    /***********************************************************************************************
    //MARK: Parse Sign Up User Function with Text Fields and Image
    ***********************************************************************************************/
    
    @IBAction func submitBtn_click(sender: AnyObject) {
        pauseApp()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let user = PFUser()
            user.username = self.usernameTxt.text
            user.email = self.emailTxt.text
            user["displayName"] = self.displayNameTxt.text
            
            let imageData = UIImagePNGRepresentation(self.profileImg.image!)
            let imageFile = PFFile(name: "profilePhoto.png", data: imageData!)
            
            // if the user did not select an image, use the default image, upload to parse as that user's image
            // Could be redundant, it seems Parse already does this when the image is there. Nonetheless, this is useful for
            // setting in-app resources to something and then uploading through Parse.
            
            if imageFile.isEqual(nil) {
                let photoName = "profileIcon.png"
                let photo = UIImage(named: photoName)
                user["photo"] = UIImagePNGRepresentation(photo!)
            } else {
                user["photo"] = imageFile
            }
            user["chatObjectIds"] = []
            user["accountStatus"] = "free"
            user.password = self.passwordTxt.text
            let birthDateString = "\(self.birthMonth.text)" + "/" + "\(self.birthDay.text)" + "/" + "\(self.birthYear.text)"
            user["birthDate"] = birthDateString
            user.signUpInBackgroundWithBlock { (succeeded:Bool, signUpError:NSError?) -> Void in
                if signUpError == nil {
                    print("signup")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.resumeApp()
                    })
                    self.performSegueWithIdentifier("goToTabsVC2", sender: self)
                } else {
                    print("can't signup")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.resumeApp()
                    })
                }
            }
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
}

/***********************************************************************************************
//MARK: CODE CLOSET
***********************************************************************************************/

