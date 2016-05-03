//
//  seecretsVC.swift
//  Seecret
//
//  Created by Matt D'Arcy on 9/4/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//


/***********************************************************************************************
//MARK: TODO
***********************************************************************************************/


import UIKit
import Parse
class seecretsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var cellIndexPath:Int = -1
    
    @IBOutlet weak var resultsTable: UITableView!

    var mySeecretNameArray = [String]()
    var mySeecretIdArray = [String]()
    
    var newSeecretIdArray = [String]()
    var newSeecretNameArray = [String]()
    
    //seecret count, start at 0 and update with the contents of the user's seecret array
    var seecretCount:Int = 0

    var accountStatus:NSString = "free"
    

    
    //assume it is true until proven otherwise
    var duplicateSeecret:Int = 0
    var randomNum2:Int = -1

    //chatObjId of the cell that was tapped to send to the conversation view
    var chatIdToFetch:String = ""
    
    
/***********************************************************************************************
//MARK: Clear contents of query arrays to avoid duplicating info on reloads
***********************************************************************************************/
    func preTreatView() {
        self.mySeecretNameArray.removeAll(keepCapacity: false)
        self.mySeecretIdArray.removeAll(keepCapacity: false)

        self.newSeecretIdArray.removeAll(keepCapacity: false)
        self.newSeecretNameArray .removeAll(keepCapacity: false)
        
        //show the title programatically because the tab controller negates the navigation title
        self.tabBarController?.navigationItem.title = "Seecrets"
        
        //show the add button programatically
        self.tabBarController?.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(seecretsVC.addSeecretBtn_click)), animated: true)
        checkAccountStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preTreatView()
        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        resultsTable.frame = CGRectMake(0,0,theWidth,theHeight - 64)
    }
    

    
    override func viewDidAppear(animated: Bool) {
        preTreatView()

/***********************************************************************************************
//MARK: Query Parse for all Seecrets for this user
***********************************************************************************************/
        let query = PFQuery(className: "Seecrets")
        query.whereKey("viewerObjectId", equalTo: userObjectID)

        query.addAscendingOrder("createdAt")
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            
            if error == nil {
                for object in objects! {
                    
                    self.mySeecretIdArray.append(object.objectForKey("chatObjectId") as! String)
                    self.mySeecretNameArray.append(object.objectForKey("chatTitle") as! String)
                    
                    
                    
                    self.resultsTable.reloadData()
                }
            }
        }
    }
    
/***********************************************************************************************
//MARK: Setup tableview and cells for seecrets
**********************************************************************************************/

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToConversationVC3" {
            if let conversationViewController = segue.destinationViewController as? conversationVC {
                conversationViewController.userParticipantType = "seecretViewer"
                print("cellIndexPath is \(cellIndexPath)")
                conversationViewController.chatObjIdFromSeecretsTab = self.mySeecretIdArray[cellIndexPath]
                conversationViewController.userAccountStatus = self.accountStatus as String
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        _ = tableView.cellForRowAtIndexPath(indexPath) as! seecretCell
        cellIndexPath = indexPath.row
        self.performSegueWithIdentifier("goToConversationVC3", sender: self)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.seecretCount = mySeecretIdArray.count
        print("and now the seecretcount is \(mySeecretIdArray.count)")
        return mySeecretIdArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:seecretCell = tableView.dequeueReusableCellWithIdentifier("SeecretCell") as! seecretCell
    
        cellIndexPath = indexPath.row
        
/***********************************************************************************************
//MARK: Keep name generic for freebie, specific for paid. See seecretCell.swift file as well
**********************************************************************************************/
        print("indexPath.row is \(indexPath.row)")
        print("mySeecretNameArrayis \(mySeecretNameArray)")
        cell.actualNameLbl.text = mySeecretNameArray[indexPath.row]
        if accountStatus == "free" {
            cell.seecretNameLbl.text = "My Free Seecret"
        } else {
            cell.seecretNameLbl.text = "Seecret \(indexPath.row+1)"
        }
        return cell
    }
    

    

    
/***********************************************************************************************
//MARK: Check if premium account (PRIME USE TO GET 1 CELL IN REAL-TIME)
***********************************************************************************************/
    func checkAccountStatus() {
        let currentUser = PFUser.currentUser()
        currentUser!.fetchInBackgroundWithBlock{
            (object, error) -> Void in
            currentUser!.fetchIfNeededInBackgroundWithBlock {
                (result, error) -> Void in
                self.accountStatus = currentUser?.objectForKey("accountStatus") as! String
            }
        }
//print("accountStatus is \(accountStatus) and seecretCount is \(self.seecretCount)")
    }
    
    
/***********************************************************************************************
//MARK: Get a new Seecret
***********************************************************************************************/
    func addSeecretBtn_click() {


/***********************************************************************************************
//MARK: Not premium and has >0 Seecrets
***********************************************************************************************/
        if accountStatus == "free" && self.seecretCount > 0 {
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "Upgrade?", message: "You must upgrade to have more than 1 active seecret.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Let's go!", style: .Default, handler: {
                    (action) -> Void in
                    //instead of segue to the page, just set the bool as true here from the uialert action
                    //there is some error with xcode sigabrt and examples online do not help
                    PFUser.currentUser()!["accountStatus"] = "premium"
                    PFUser.currentUser()!.saveInBackground()
                    self.accountStatus = "premium"
                    self.resultsTable.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Nevermind", style: .Default, handler: {
                    (action) -> Void in
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
/***********************************************************************************************
//MARK: Not Premium and No Seecrets
***********************************************************************************************/
            
        } else if accountStatus == "free" {
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "New Seecret", message: "As a basic user, you may have 1 seecret at a time.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Get my seecret!", style: .Default, handler: {
                    (action) -> Void in
                    
                    
                    //Query all chats that exist
                    let query = PFQuery(className: "Chats")
                    query.findObjectsInBackgroundWithBlock {
                        (objects, error) -> Void in
                        print("objects is \(objects)")
                        if let objs = objects {
                            for object in objs {
                                let objectId = object.objectId as String!
                                print("chatObjId is \(objectId)")
                                self.newSeecretIdArray.append(objectId)
                                self.newSeecretNameArray.append(object["chatTitle"] as! String)
                            }
                            print("the amount of things in resultsNameArray2 is \(self.newSeecretIdArray.count)")
                            print("the chatsIdArray is \(self.newSeecretIdArray)")
                            let randomIndex = Int(arc4random_uniform(UInt32(self.newSeecretIdArray.count)))
                            
                            print("the random number is \(randomIndex)")
                            print("the random selection is \(self.newSeecretNameArray[randomIndex])")
                            
                            self.mySeecretIdArray.append(self.newSeecretIdArray[randomIndex])
                            self.mySeecretNameArray.append(self.newSeecretNameArray[randomIndex])
                            
                            let seecretObj = PFObject(className: "Seecrets")
                            seecretObj["viewerObjectId"] = userObjectID
                            seecretObj["viewerUsername"] = userName
                            seecretObj["chatTitle"] = self.newSeecretNameArray[randomIndex] as String
                            seecretObj["chatObjectId"] = self.newSeecretIdArray[randomIndex] as String
                            
                            seecretObj.saveInBackground()
                            self.resultsTable.reloadData()
                        }
                        
                    }
                    
                    
                    self.seecretCount += 1
                    print("seecret count is now \(self.seecretCount)")
                    
                    
                }))
                alert.addAction(UIAlertAction(title: "Nevermind", style: .Default, handler: {
                    (action) -> Void in
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
            
            
/***********************************************************************************************
//MARK: Is premium, get a seecret and watch out for duplicates
***********************************************************************************************/
        } else if accountStatus == "premium" {
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "New Seecret", message: "Add another seecret?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Get my seecret!", style: .Default, handler: {
                    (action) -> Void in
                    
                    
                    
                    let query = PFQuery(className: "Chats")
                    query.findObjectsInBackgroundWithBlock {
                        (objects, error) -> Void in
                        if error == nil {
                            for object in objects! {
                                let objectId = object.objectId as String!
                                print("chatObjId ia \(objectId)")
                                self.newSeecretIdArray.append(objectId)
                                self.newSeecretNameArray.append(object.objectForKey("chatTitle") as! String)
                            }
                            var randomIndex = Int(arc4random_uniform(UInt32(self.newSeecretIdArray.count)))
                            let randomIndexSave = randomIndex
                            print("the random number is \(randomIndex)")
                            print("the random selection is \(self.newSeecretNameArray[randomIndex])")
                            
                            self.mySeecretIdArray.append(self.newSeecretIdArray[randomIndex])
                            
                            //Prevent duplicates in the table list
                            //randomNum set at -1. goes through whole seecret list and checks if there is a duplicate. If there is, kicks to true where it will loop through again with the newly tried quantity until it goes through as false
                            
                            repeat {
                                repeat  {
                                    if randomIndex == -1 {
                                        print("randomindex was at -1")
                                        randomIndex = randomIndexSave
                                        print("randomindex is now what it was before at \(randomIndex)")
                                    }
                                    
                                    
                                    
                                    
                                    
                                    randomIndex = self.preventDuplicates(randomIndex, randomCount: self.mySeecretIdArray.count, seecretArray: self.mySeecretIdArray, downloadedChatArray: self.newSeecretIdArray)
                                    

                                    
                                } while self.randomNum2 == -1
                                //new number, randomNum2 is tested
                                print("check3")
                                for i in 0...self.mySeecretIdArray.count {
                                    print("mySeecretIdArray[\(i)] is \(self.mySeecretIdArray[i])")
                                    print("self.newSeecretIdArray[\(self.randomNum2)] is \(self.newSeecretIdArray[self.randomNum2])")

                                    if self.mySeecretIdArray[i] as String != self.newSeecretIdArray[self.randomNum2] as String {
                                        print("mySeecretIdArray[\(i)] is \(self.mySeecretIdArray[i] as String) and newSeecretIdArray[\(self.randomNum2)] is \(self.newSeecretIdArray[self.randomNum2] as String)")
                                        print("duplicate flag is ZERO, exiting loop")
                                    } else if self.mySeecretIdArray[i] as String == self.newSeecretIdArray[self.randomNum2] as String {
                                        print("mySeecretIdArray[\(i)] is \(self.mySeecretIdArray[i] as String) and newSeecretIdArray[\(self.randomNum2)] is \(self.newSeecretIdArray[self.randomNum2] as String)")
                                        self.duplicateSeecret = 1
                                        print("duplicate flag is ONE, re-entering loop")
                                    }
                                }
                            } while self.duplicateSeecret == 1
                            
                            
                            print("loop over, final random number is \(randomIndex)")
                            print("loop over, final chatId is \(self.newSeecretIdArray[randomIndex])")
                            print("loop over, final chatTitle number is \(self.newSeecretNameArray[randomIndex])")
                            self.mySeecretIdArray.append(self.newSeecretIdArray[randomIndex])
                            self.mySeecretNameArray.append(self.newSeecretNameArray[randomIndex])
                            let seecretObj = PFObject(className: "Seecrets")
                            seecretObj["viewerObjectId"] = userObjectID
                            seecretObj["viewerUsername"] = userName
                            seecretObj["chatTitle"] = self.newSeecretNameArray[randomIndex] as String
                            seecretObj["chatObjectId"] = self.newSeecretIdArray[randomIndex] as String
                            self.seecretCount += 1
                            print("seecret count is now \(self.seecretCount)")
                            seecretObj.saveInBackground()
                            
                        }
                    }
                    
                    
                    self.resultsTable.reloadData()
                    
                }))
                alert.addAction(UIAlertAction(title: "Nevermind", style: .Default, handler: {
                    (action) -> Void in
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            } else {
                // Fallback on earlier versions
            }
            
    }

    
/***********************************************************************************************
//MARK: Do not allow duplicate seecrets. If one exists in the list already, keep trying till one is found
***********************************************************************************************/
        
    func preventDuplicates(randomNum:Int, randomCount:Int, seecretArray:[String], downloadedChatArray:[String]) -> Int{
        print("check1")
        print("seecretArray is \(seecretArray)")
        var i:Int = 0
        
        
//for each seecret in this user's seecret list
        for i in 0...randomCount {
// see if the randomly selected chatroom has the same name as any of the seecrets on the list
            print("randomNum is \(randomNum) and i is \(i)")
            
            print("downloadedChatArray is \(downloadedChatArray)")
            print("seecretArray is \(seecretArray)")
            print("downloadedChatArray[\(randomNum)] is \(downloadedChatArray[randomNum])")
            print("seecretArray[\(i)] is \(seecretArray[i])")
            
            
            print("downloadedChatArray[randomNum] is \(downloadedChatArray[randomNum]) and seecretArray[i] is \(seecretArray[i])")
            if downloadedChatArray[randomNum] == seecretArray[i] {
                print("check2, DUPLICATE TRUE")
//if a single match is found, set the flag
                self.duplicateSeecret = 1
            }
        }

        
//if the flag is set, pick a new number
        if duplicateSeecret == 1 {
            print("picking a new number!!!")
//pick another random chatroom and do so until there is a unique one
            repeat {
                print("picking new number...")
                randomNum2 = Int(arc4random_uniform(UInt32(self.newSeecretIdArray.count)))
                print("I picked the number \(randomNum2)")
            } while randomNum2 == randomNum
            print("returning new number randomNum2 = \(randomNum2)")
        }
        
        
//if no matches were found at all, make randomNum2 = randomNum for output
        if duplicateSeecret == 0 {
            randomNum2 = randomNum
        }
//reset flag
        self.duplicateSeecret = 0
//If -1, it will loop again. If not -1, it will make sure there are no duplicates
        return randomNum2

    }
    

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


/***********************************************************************************************
//MARK: CODE CLOSET
***********************************************************************************************/

