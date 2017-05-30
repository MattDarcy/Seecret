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
import CoreData



//NSFetchedResultsControllerDelegate for CoreData
class friendsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var cellIndexPath:Int = -1
    
    /***********************************************************************************************
    //MARK: Core Data Context, nItem, and newItem()
    ***********************************************************************************************/
    let context:NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var nItem : Friend? = nil
    
    var frc:NSFetchedResultsController = NSFetchedResultsController()
    
    func getFetchResultsController() -> NSFetchedResultsController {
        frc = NSFetchedResultsController(fetchRequest: ListFetchRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }

    func ListFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Friend")
        //sorts list by alphabetical item
        let sortDescriptor = NSSortDescriptor(key: "friendDisplayName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    var coreDataContent:Bool = false
    var didLoad:Bool = false
    var i = 0
    var j = 0
    
    @IBOutlet weak var resultsTable: UITableView!
    
    var resultsObjectIdsArray = [String]()
    var resultsUsernameArray = [String]()
    var resultsDisplayNameArray = [String]()
    var resultsImageFiles = [PFFile]()
    
    func preTreatView() {
        //assign for CoreData
        frc = getFetchResultsController()
        frc.delegate = self
        try! frc.performFetch()
        
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
        button.target = targetForAction("", withSender: nil)
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
        
        if coreDataContent == true {
            //fill the table with friends data from coredata
            print("I will not get more data from Parse for friends.")
        } else {
            /***********************************************************************************************
            //MARK: Query friends list for current user, then individual friends' data, save to CoreData and reload
            ***********************************************************************************************/
             //let userObjectID = PFUser.currentUser()!.objectId!
             //let userName = PFUser.currentUser()!.username!
            
             //var predicate = NSPredicate(format: "userObjectId = '"+userObjectID+"'")
            //var query = PFQuery(className: "Friends", predicate: predicate)
//            query.findObjectsInBackgroundWithBlock {
//                (objects:[AnyObject]?, error:NSError?) -> Void in
//                if let objs = objects {
//                    for object in objs {
//                        self.resultsObjectIdsArray = (object["friendsObjectIds"] as! Array!)
//                        self.resultsDisplayNameArray = (object["friendsDisplayNames"] as! Array!)
//                    }
//                }
//                for (self.i = 0; self.i < self.resultsObjectIdsArray.count; self.i++) {
//                    predicate = NSPredicate(format: "objectId = '"+self.resultsObjectIdsArray[self.i]+"'")
//                    query = PFQuery(className: "_User", predicate: predicate)
//                    query.findObjectsInBackgroundWithBlock({
//                        (objects:[AnyObject]?, error:NSError?) -> Void in
//                        if let objs = objects {
//                            for object in objs {
//                                self.resultsUsernameArray.append(object.username! as String!)
//                                self.resultsImageFiles.append(object["photo"] as! PFFile)
//                                
//                                let context = self.context
//                                let ent = NSEntityDescription.entityForName("Friend", inManagedObjectContext: context)
//                                let nItem2 = Friend(entity: ent!, insertIntoManagedObjectContext: context)
//                                
//                                var name = self.resultsDisplayNameArray[self.j]
//                                nItem2.friendDisplayName = self.resultsDisplayNameArray[self.j]
//                                nItem2.friendObjectId = self.resultsObjectIdsArray[self.j]
//                                print("friendDisplayName saved in data is \(nItem2.friendDisplayName)")
//                                print("friendObjectId saved in data is \(nItem2.friendObjectId)")
//                                
//                                nItem2.friendUsername = object.username! as String!
//                                print("friendUsername saved in data is \(nItem2.friendUsername)")
//                                
//                                let userImageFile = object["photo"] as! PFFile
//                                userImageFile.getDataInBackgroundWithBlock({
//                                    (imageData:NSData?, error:NSError?) -> Void in
//                                    if error == nil {
//                                        let image = UIImage(data: imageData!)
//                                        nItem2.friendPhoto = UIImagePNGRepresentation(image!)!
//                                        self.coreDataContent = true
//                                        do {
//                                            try context.save()
//                                        } catch {
//                                            print("problem");
//                                        }
//                                    }
//                                })
//                                self.j++
//                            }
//                        }
//                    })
//                }
//            }
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
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! friendsCell
        cellIndexPath = indexPath.row
        self.performSegueWithIdentifier("goToConversationVC", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return resultsObjectIdsArray.count
        
        let numberOfRowsInSection = frc.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = frc.sections?.count
        return numberOfSections!
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
        
        if let friend = frc.objectAtIndexPath(indexPath) as? Friend {
            print("nItem has contents")
            coreDataContent = true
            cell.profileNameLbl?.text = friend.friendDisplayName
            cell.profileImg?.image = UIImage(data: (friend.friendPhoto))
            
            resultsObjectIdsArray.append(friend.friendObjectId)
            resultsDisplayNameArray.append(friend.friendDisplayName)
            print("I retrieved from coredata resultsObjectIdsArray \(resultsObjectIdsArray) and resultsDisplayNameArray \(resultsDisplayNameArray)" )
            
        }
        
        print("friendObjectIdArray is now \(resultsObjectIdsArray)")
        
        return cell
    }
    
/***********************************************************************************************
//MARK: Swipe left to delete
***********************************************************************************************/
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let managedObject: NSManagedObject = frc.objectAtIndexPath(indexPath) as! NSManagedObject
        context.deleteObject(managedObject)
        do {
            try context.save()
        } catch {
            print("problem");
        }
        
        
        
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
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        resultsTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


/***********************************************************************************************
//MARK: CODE CLOSET
***********************************************************************************************/


