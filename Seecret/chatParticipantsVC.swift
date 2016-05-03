//
//  chatParticipantsVC.swift
//  Seecret
//
//  Created by Matt D'Arcy on 10/28/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//


/***********************************************************************************************
//MARK: TODO
***********************************************************************************************/

import UIKit
import Parse
class chatParticipantsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var cellIndexPath:Int = -1
    
    @IBOutlet weak var resultsTable: UITableView!
    
    var chatParticipantIdsArray = [String]()
    var chatAdminIdsArray = [String]()
    var chatParticipantUsernameArray = [String]()
    var chatParticipantDisplayNameArray = [String]()
    var chatParticipantImagePFFiles = [PFFile]()
    var chatParticipantImageUIFiles = [UIImage]()
    var i:Int = 0
    var thisChatId:String = ""
    
    var userId = PFUser.currentUser()?.objectId
    var userDisplayName:String = ""
    
    var userParticipantType:String = ""
    
    var fromConversation:Bool = false
    
    func pretreatView() {
        //self.navigationItem.title = "Chat Participants"
    }
    

    
    override func viewDidAppear(animated: Bool) {
        pretreatView()
        getData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func clearArrays() {
        chatParticipantIdsArray.removeAll(keepCapacity: false)
        chatAdminIdsArray.removeAll(keepCapacity: false)
        chatParticipantUsernameArray.removeAll(keepCapacity: false)
        //chatParticipantDisplayNameArray.removeAll(keepCapacity: false)
        chatParticipantImagePFFiles.removeAll(keepCapacity: false)
        chatParticipantImageUIFiles.removeAll(keepCapacity: false)
    }
    
    func getData() {
        print("fromConvo is now \(fromConversation)")
        if fromConversation == true {
            clearArrays()
            let predicate = NSPredicate(format: "objectId = '"+thisChatId+"'")
            var query = PFQuery(className: "Chats", predicate: predicate)
            query.findObjectsInBackgroundWithBlock {
                (objects, error) -> Void in
                
                if let objs = objects {
                    for object in objs {
                        self.chatParticipantIdsArray = (object["chatParticipantIds"] as! Array!)
                        self.chatAdminIdsArray = (object["adminIds"] as! Array!)
                        if self.chatParticipantDisplayNameArray == [] {
                            print("displaynames array was empty, getting the real ones")
                            self.chatParticipantDisplayNameArray = (object["chatParticipantDisplayNames"] as! Array!)
                        } else {
                            print("displaynames array was not empty, seecret makeover")
                            print(self.chatParticipantDisplayNameArray)
                        }
                        
                        if self.userParticipantType == "seecretViewer" {

                            for _ in 0...self.chatParticipantDisplayNameArray.count {
                                self.chatParticipantImageUIFiles.append(UIImage(named: "profileIcon")!)
                            }
                            
                        } else {
                            
                        }
                        
                        
                        //to remove the current user from the display:
                        /*
                        var index1 = find(self.chatParticipantIdsArray, self.userId!)
                        var index2 = find(self.chatParticipantDisplayNameArray, self.userDisplayName)
                        self.chatParticipantIdsArray.removeAtIndex(index1!)
                        self.chatParticipantDisplayNameArray.removeAtIndex(index2!)
                        */
                        
                        repeat {
                            print("i is \(self.i)")
                            print("getting the image for userId \(self.chatParticipantIdsArray[self.i])")
                            query = PFUser.query()!
                            query.whereKey("objectId", equalTo: self.chatParticipantIdsArray[self.i])
                            do {
                                let objects = try query.findObjects()
                                print(objects)
                                if let objs = objects as [PFObject]? {
                                    for object in objs {
                                        if let userImgPFFile = object.valueForKey("photo") as? PFFile {
                                            print("found photo")
                                            do {
                                                let userImgData = try userImgPFFile.getData()
                                                print("got photo")
                                                let userImgUI = UIImage(data: userImgData)
                                                self.chatParticipantImageUIFiles.append(userImgUI!)
                                                print("photo count is  \(self.chatParticipantImageUIFiles.count)")
                                            } catch _ {
                                                //handle error
                                            }
                                            
                                            /*
                                             userPicture.getDataInBackgroundWithBlock({
                                             (imageData: NSData?, error: NSError?) -> Void in
                                             
                                             if (error == nil) {
                                             
                                             let image = UIImage(data:imageData!)
                                             self.chatParticipantImageUIFiles.append(image!)
                                             println("image count is \(self.chatParticipantImageUIFiles.count)")
                                             self.i++
                                             println("getting the image for userId \(self.chatParticipantIdsArray[self.i])")
                                             query.whereKey("objectId", equalTo: self.chatParticipantIdsArray[self.i])
                                             }
                                             
                                             })
                                             */
                                        }
                                        
                                    }
                                    
                                }
                                
                                self.i += 1
                                print("i is now \(self.i)")
                            } catch {
                                //handle error
                            }
                            
                        } while (self.i < self.chatParticipantIdsArray.count)
                        
                        
                        self.resultsTable.reloadData()
                        
                    }
                }
            }

        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextViewController: profileVC = segue.destinationViewController as! profileVC
        if(segue.identifier == "goToProfileVC") {
            //println("chatIDToFetch is \(self.chatIdToFetch)")
            nextViewController.thisUserId = chatParticipantIdsArray[cellIndexPath]
            nextViewController.thisDisplayName = chatParticipantDisplayNameArray[cellIndexPath]
            nextViewController.thisUserImg = chatParticipantImageUIFiles[cellIndexPath]
            fromConversation = false
            //fix this when the images are working in the participants list
            //nextViewController.thisProfileImage = UIImage(named: "")!
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:chatParticipantCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! chatParticipantCell
        cell.profileImg.image = self.chatParticipantImageUIFiles[indexPath.row]
        cellIndexPath = indexPath.row
        cell.profileNameLbl.text = (self.chatParticipantDisplayNameArray[indexPath.row] as String)
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatParticipantIdsArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        cellIndexPath = indexPath.row
        self.performSegueWithIdentifier("goToProfileVC", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0
    }
    */
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
    
    // Configure the cell...
    
    return cell
    }
    */
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}


/***********************************************************************************************
//MARK: CODE CLOSET
***********************************************************************************************/


