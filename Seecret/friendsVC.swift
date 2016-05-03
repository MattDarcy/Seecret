//
//  friendsVC.swift
//  Seecret
//
//  Created by Matt D'Arcy on 8/14/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//

/***********************************************************************************************
//MARK: TODO
***********************************************************************************************/
// Download remaining friends for user if not all are in core data
// Core data and data transmissions seem to work well here, however the whole one-by-one thing is a little awkward.
// if not implement all downloads/coredata saves in a single background class then figure out a solid algorithm for this view and implement on all other views.
// Have continuity, if a user deletes a friend they are deleted from view, core data, as well as server.


import UIKit
import Parse
let userObjectID = PFUser.currentUser()!.objectId!
let userName = PFUser.currentUser()!.username!

//NSFetchedResultsControllerDelegate for CoreData
class friendsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cellIndexPath:Int = -1
    
    var didLoad:Bool = false
    var i = 0
    var j = 0
    
    @IBOutlet weak var resultsTable: UITableView!
    
    var resultsObjectIdsArray = [String]()
    var resultsUsernameArray = [String]()
    var resultsDisplayNameArray = [String]()
    var resultsImageFiles = [PFFile]()
    
    func preTreatView() {
        
        /***********************************************************************************************
        //MARK: Hide back button and show title on tab view
        ***********************************************************************************************/
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.title = "Friends"
        
        /***********************************************************************************************
        //MARK: Add hamburger menu button
        ***********************************************************************************************/
        let button: UIBarButtonItem = UIBarButtonItem()
        button.image = UIImage(named: "hamburger")
        button.target = targetForAction(Selector(""), withSender: nil)
        self.tabBarController?.navigationItem.rightBarButtonItem = button
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preTreatView()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        preTreatView()
        /***********************************************************************************************
        //MARK: Clear contents of query arrays to avoid duplicating info on reloads
        ***********************************************************************************************/
        resultsUsernameArray.removeAll(keepCapacity: false)
        resultsDisplayNameArray.removeAll(keepCapacity: false)
        resultsImageFiles.removeAll(keepCapacity: false)
        
            /***********************************************************************************************
            //MARK: Query friends list for current user, then individual friends' data, save to CoreData and reload
            ***********************************************************************************************/
            var predicate = NSPredicate(format: "userObjectId = '"+userObjectID+"'")
            var query = PFQuery(className: "Friends", predicate: predicate)
            query.findObjectsInBackgroundWithBlock {
                (objects, error) -> Void in
                if let objs = objects {
                    for object in objs {
                        self.resultsObjectIdsArray = (object["friendsObjectIds"] as! Array!)
                        self.resultsDisplayNameArray = (object["friendsDisplayNames"] as! Array!)
                    }
                }
                for _ in 0...self.resultsObjectIdsArray.count {
                    predicate = NSPredicate(format: "objectId = '"+self.resultsObjectIdsArray[self.i]+"'")
                    query = PFQuery(className: "_User", predicate: predicate)
                    query.findObjectsInBackgroundWithBlock({
                        (objects, error) -> Void in
                        if let objs = objects {
                            for object in objs {
                                self.resultsUsernameArray.append(object["username"] as! String!)
                                self.resultsImageFiles.append(object["photo"] as! PFFile)
                                
                                let userImageFile = object["photo"] as! PFFile
                                userImageFile.getDataInBackgroundWithBlock({
                                    (imageData:NSData?, error:NSError?) -> Void in
                                    if error == nil {
                                        let _ = UIImage(data: imageData!)
                                        
                                    }
                                })
                                self.j += 1
                            }
                        }
                    })
                }
            }
        
    }

    

    
    /***********************************************************************************************
    //MARK: Setup friends tableview and cells
    ***********************************************************************************************/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextViewController: conversationVC = segue.destinationViewController as! conversationVC
        if(segue.identifier == "goToConversationVC") {
            print("friends tab pushing indexPath.row \(cellIndexPath) and other userId \(self.resultsObjectIdsArray[cellIndexPath])")
            print("the entire array is \(self.resultsObjectIdsArray)")
            nextViewController.otherUserId = self.resultsObjectIdsArray[cellIndexPath]
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        _ = tableView.cellForRowAtIndexPath(indexPath) as! friendsCell
        cellIndexPath = indexPath.row
        self.performSegueWithIdentifier("goToConversationVC", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsObjectIdsArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:friendsCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! friendsCell
        //cell.usernameLbl.text = self.resultsUsernameArray[indexPath.row]
        //cell.profileNameLbl.text = self.resultsDisplayNameArray[indexPath.row]
        
        //resultsImageFiles[indexPath.row].getDataInBackgroundWithBlock { (imageData:NSData?, error:NSError?) -> Void in
        //if error == nil {
        //let image = UIImage(data: imageData!)
        //cell.profileImg.image = image
        //}
        //}
        
        cellIndexPath = indexPath.row

        print("friendObjectIdArray is now \(resultsObjectIdsArray)")
        
        return cell
    }
    
/***********************************************************************************************
//MARK: Swipe left to delete
***********************************************************************************************/
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        /*
        println("resultsObjectIdsArray is \(resultsObjectIdsArray)  and index path is \(indexPath.row)")
        var rowNum = indexPath.row+1
        println("rowNum is \(rowNum)")
        
        var friendIdToDelete = resultsObjectIdsArray[rowNum] as String
        println("check1")
        var friendDisplayNameToDelete = resultsDisplayNameArray[rowNum] as String
        
        println("I will delete the friendId \(friendIdToDelete) and the displayName \(friendDisplayNameToDelete)")
        
        
        
        
        
        var predicate = NSPredicate(format: "userObjectId = '"+userObjectID+"'")
        var query = PFQuery(className: "Friends", predicate: predicate)
        query.findObjectsInBackgroundWithBlock {
        (objects:[AnyObject]?, error:NSError?) -> Void in
        if let objs = objects {
        for object in objs {
        println(object)
        object.removeObjectsInArray(["\(friendIdToDelete)"], forKey: "friendsObjectIds")
        object.removeObjectsInArray(["\(friendDisplayNameToDelete)"], forKey: "friendsDisplayNames")
        }
        }
        }
        */
        
        
        
        
    }
  
    /***********************************************************************************************
    //MARK: Hide navigation bar back button when this view loads from another screen
    ***********************************************************************************************/
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


/***********************************************************************************************
//MARK: CODE CLOSET
***********************************************************************************************/


