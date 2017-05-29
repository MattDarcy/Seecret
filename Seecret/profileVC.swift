//
//  profileVC.swift
//  Seecret
//
//  Created by Matt D'Arcy on 11/2/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//

import UIKit
import Parse

class profileVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var displayNameLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var editImgBtn: UIButton!
    
    var thisUserId:String = ""
    var thisDisplayName:String = ""
    var thisUserImg:UIImage!
    //image coming from previous view when ready
    //var thisProfileImage:UIImage = UIImage(named: "")!
    
    func preTreatView() {
        if PFUser.currentUser()?.objectId == thisUserId {
            editImgBtn.hidden = false
        }
        profileImg.image = thisUserImg
        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        profileImg.clipsToBounds = true
        displayNameLbl.text = thisDisplayName
        self.navigationItem.title = "Profile View"
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preTreatView()
    }
    
    
    
    
    @IBAction func editImgBtn_Press(sender: AnyObject) {
        let img = UIImagePickerController()
        img.delegate = self
        img.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        img.allowsEditing = true
        self.presentViewController(img, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        profileImg.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
        
        print("photo updated")
        
        let query = PFQuery(className: "_User")
        query.getObjectInBackgroundWithId(self.thisUserId){
            (user:PFObject?,error:NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let user = user {
                let imageData = UIImagePNGRepresentation(self.profileImg.image!)
                let imageFile = PFFile(name:"editedPhoto.png", data:imageData!)
                print("check1")
                //user["photo"] = imageFile
                print("check3")
                print("Photo updated at server")
                user["photo"] = imageFile
//                user.save()
                print("check4")
 
            }
        }
        
        /*
        
        var predicate = NSPredicate(format: "objectId = '"+self.thisUserId+"'")
        var chatObj2 = PFQuery(className: "_User", predicate: predicate)
        chatObj2.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]?, error:NSError?) -> Void in
            if error == nil {
                if let objs = objects {
                    for object in objs {

                        let imageData = UIImagePNGRepresentation(self.profileImg.image)
                        let imageFile = PFFile(name:"editedPhoto.png", data:imageData)
                        println("check1")
                        if imageFile.isEqual(nil) {
                            var photoName = "profileIcon.png"
                            println("check2")
                            var photo = UIImage(named: photoName)
                            object.addUniqueObject(UIImagePNGRepresentation(photo), forKey: "photo")
                            //user["photo"] = UIImagePNGRepresentation(photo)
                        } else {
                            //user["photo"] = imageFile
                            println("check3")
                            object.addUniqueObject(imageFile, forKey: "photo")
                        }
                        println("check4")
                        
                        object.save()
                        println("Photo updated at server")
                    }
                }
            }
        })

        */


        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
