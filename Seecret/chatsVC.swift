//
//  chatsVC.swift
//  Seecret
//
//  Created by Matt D'Arcy on 8/27/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//


/***********************************************************************************************
//MARK: TODO
***********************************************************************************************/


import UIKit
import Parse
import CoreData

class chatsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    /***********************************************************************************************
     //MARK: UIActivity Spinner
     ***********************************************************************************************/
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
//    func pauseApp() {
//        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
//        activityIndicator.center = self.view.center
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
//        activityIndicator.layer.zPosition = 1
//        view.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
//        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
//    }
    
    func resumeApp() {
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    

    @IBOutlet weak var resultsTable: UITableView!
    
    var userObjectID = ""
    var userDisplayName = ""
    
//single dimensional arrays comprising the display names and images for the last speaker of each chat. will populate the display name and image of each cell of the chat list
    var resultsNameArray = [String]()
    var resultsImageFiles = [PFFile]()
    
//array of chat object ID's stored in the User class. This data will be used to scrape data of each chat.
    var resultsObjectIds = [String]()
    
    
//arrays of the data related to chats in the Chat class
//People who have participation in the chat
    var thisChatsParticipantsIds = [String]()
    var thisChatsParticipantDisplayNames = [String]()
//title of the chat, not unique
    var chatTitles = [String]()
//people who have admin rights to the chat
    var thisChatsAdminIds = [String]()
    var thisChatsAdminUsernames = [String]()
//then we need 2D arrays to encompass them
    var chatsParticipantsIds = Array<Array<String>>()
    var chatsParticipantDisplayNames = Array<Array<String>>()
    var chatsAdminIds = Array<Array<String>>()
    var chatsAdminUsernames = Array<Array<String>>()
    
    
//arrays of the data related to a given chat in the Messages class. Will scrape all of this for each chat
//this is the array for all the chat messages within a single chat
    var thisChatsMessages = [String]()
//goes hand in hand with thisChatsMessages, so one user's id can be listed many times
    var thisChatsMessageSenders = [String]()
//all the timestamps of the messages
    var thisChatsTimestamps = [String]()
//we have an array of chatIDs each collecting arrays of chat messages, so this will need a 2D array of strings
//the same is done for timestamps and the sender id's
    var chatMessages = Array<Array<String>>()
    var chatMessageSenders = Array<Array<String>>()
    var chatTimestamps = Array<Array<String>>()
    
//while the table is populating, this will let it know to continue until it has completed
    var currResult = 0
    var results = 0
    
//chatObjId of the cell that was tapped to send to the conversation view
    var chatIdToFetch:String = ""
    
/***********************************************************************************************
//MARK: Clear contents of query arrays to avoid duplicating info on reloads
***********************************************************************************************/
    func clearArrayContents() {
        self.resultsObjectIds.removeAll(keepCapacity: false)
        self.thisChatsParticipantsIds.removeAll(keepCapacity: false)
        self.thisChatsParticipantDisplayNames.removeAll(keepCapacity: false)
        self.chatTitles.removeAll(keepCapacity: false)
        self.thisChatsAdminIds.removeAll(keepCapacity: false)
        self.thisChatsAdminUsernames.removeAll(keepCapacity: false)
        self.chatsParticipantsIds.removeAll(keepCapacity: false)
        self.chatsParticipantDisplayNames.removeAll(keepCapacity: false)
        self.chatsAdminIds.removeAll(keepCapacity: false)
        self.chatsAdminUsernames.removeAll(keepCapacity: false)
        
        self.thisChatsMessages.removeAll(keepCapacity: false)
        self.thisChatsMessageSenders.removeAll(keepCapacity: false)
        self.chatMessages.removeAll(keepCapacity: false)
        self.chatMessageSenders.removeAll(keepCapacity: false)
        self.thisChatsTimestamps.removeAll(keepCapacity: false)
        self.chatTimestamps.removeAll(keepCapacity: false)
        
        self.resultsNameArray.removeAll(keepCapacity: false)
        self.resultsImageFiles.removeAll(keepCapacity: false)
    }
    
    func preTreatView() {
//assign for CoreData
        //frc = getFetchResultsController()
        //frc.delegate = self
        //frc.performFetch(nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getMessageFunc", name: "getMessage", object: nil)
        
//show the title programatically because the tab controller negates the navigation title
        self.tabBarController?.navigationItem.title = "Chats"
//show the add button programatically
        self.tabBarController?.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addChatBtn_click"), animated: true)
        //self.userObjectID = PFUser.currentUser()!.objectId!
        //self.userDisplayName = PFUser.currentUser()?.objectForKey("displayName") as! String
    }
    
    func getMessageFunc() {
        //if the chat is not here yet, put the chat obj id in the user class for that user
        
        let pushAppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let updateChatId = pushAppDelegate.chatObjIdToUpdateInApp
        let updateMessage = pushAppDelegate.chatMessageToUpdateInApp
        
        print("the chatObjId from the push is \(updateChatId) and the message is: \(updateMessage)")
        
        if self.resultsObjectIds.contains(updateChatId as String){
            print("chat already present, just update message")
            self.queryChats()
        } else {
            print("did not exist, registering chat participation for User class")
            let predicate = NSPredicate(format: "objectId = '"+self.userObjectID+"'")
            let chatObj2 = PFQuery(className: "_User", predicate: predicate)
//            chatObj2.findObjectsInBackgroundWithBlock({
//                (objects:[AnyObject]?, error:NSError?) -> Void in
//                if error == nil {
//                    if let objs = objects {
//                        for object in objs {
//                            object.addUniqueObject(updateChatId, forKey: "chatObjectIds")
//                            object.save()
//                            self.queryChats()
//                        }
//                    }
//                }
//            })
        }
        
        
        //then either way do the scheme to get the last message for the chat that was updated and reload results
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
        queryChats()
    }
    
    func queryChats() {
        //pauseApp()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
            self.clearArrayContents()
            // if coreDataContent == true {
            //     //println("I will not get more data from Parse for chats.")
            // } else {
            /***********************************************************************************************
            //MARK: Query Parse for user's chats and each chat's info/messages
            ***********************************************************************************************/
            var predicate = NSPredicate(format: "objectId = '"+self.userObjectID+"'")
            var query = PFQuery(className: "_User", predicate: predicate)
//            var objects = query.findObjects()
//            //query.addAscendingOrder("group")
//            if let objs = objects {
//                for object in objs {
//                    
//                    //get the unique opbjectId's of each chat the user has participation in
//                    self.resultsObjectIds = (object["chatObjectIds"] as! Array)
//                    print(self.resultsObjectIds)
//                    print(self.resultsObjectIds.count)
//                    
//                    
//                }
//            }
            
            //get the data for each chat from the Chats class
            for (var i = 0; i < self.resultsObjectIds.count; i++) {
                let thisChatId:String = self.resultsObjectIds[i]
                predicate = NSPredicate(format: "objectId = '"+thisChatId+"'")
                query = PFQuery(className: "Chats", predicate: predicate)
//                objects = query.findObjects()
//                if let objs = objects {
//                    print("objects found are: \(objs)")
//                    for object in objs {
//                        //get this chat's data in 1d arrays
//                        self.thisChatsParticipantsIds = (object["chatParticipantIds"] as! Array!)
//                        self.thisChatsParticipantDisplayNames = (object["chatParticipantDisplayNames"] as! Array!)
//                        self.chatTitles.append(object["chatTitle"] as! String!)
//                        self.thisChatsAdminIds = (object["adminIds"] as! Array!)
//                        self.thisChatsAdminUsernames = (object["adminUsernames"] as! Array!)
//                        
//                        //put into the 2d arrays as a (row,col??)
//                        self.chatsParticipantsIds.append(self.thisChatsParticipantsIds)
//                        self.chatsParticipantDisplayNames.append(self.thisChatsParticipantDisplayNames)
//                        self.chatsAdminIds.append(self.thisChatsAdminIds)
//                        self.chatsAdminUsernames.append(self.thisChatsAdminUsernames)
//                        print("chatsParticipantIds array is \(self.chatsParticipantsIds)")
//                        print("chatsParticipantsDisplayNames array is \(self.chatsParticipantDisplayNames)")
//                        print("chatsAdminIds array is \(self.chatsAdminIds)")
//                        print("chatsAdminUsernames array is \(self.chatsAdminUsernames)")
//                        //clear the 1D arrays for next iteration and iterate k(row/col??) counter
//                        self.thisChatsParticipantsIds.removeAll(keepCapacity: false)
//                        self.thisChatsParticipantDisplayNames.removeAll(keepCapacity: false)
//                        self.thisChatsAdminIds.removeAll(keepCapacity: false)
//                        self.thisChatsAdminUsernames.removeAll(keepCapacity: false)
//                    }
//                    
//                    //for each chat the user has participation in, grab the messages for that chat (2D array) from Messages class
//                    predicate = NSPredicate(format: "chatObjectId = '"+self.resultsObjectIds[i]+"'")
//                    query = PFQuery(className: "Messages", predicate: predicate)
//                    //organize by timestamp with most recent first
//                    query.addDescendingOrder("createdAt")
//                    //This pulls all messages for a specific chat as objects
//                    objects = query.findObjects()
//                    if let objs = objects{
//                        for object in objs {
//                            //this gets createdAt time from Parse (UTC/GMT) and needs to be converted to user's timezone
//                            let date = object.createdAt as NSDate?
//                            let dateFormatter = NSDateFormatter()
//                            //get calendar
//                            let calendar = NSCalendar.currentCalendar()
//                            //Get just MM/dd/yyyy from current date
//                            let flags: NSCalendarUnit = [.Day, .Month, .Year]
//                            let components = calendar.components(flags, fromDate: NSDate())
//                            
//                            //Convert to NSDate
//                            let today = calendar.dateFromComponents(components)
//                            if  date!.timeIntervalSinceDate(today!).isSignMinus{
//                                //if the last message timestamp before today, show date
//                                //full data format is: "yyyy-MM-dd HH:mm:ss"
//                                dateFormatter.dateFormat = "MM-dd-yy"
//                            } else {
//                                //if the last message timestamp was today, show the time
//                                // need upper-case HH to go over 12 hour count.
//                                dateFormatter.dateFormat = "HH:mm"
//                            }
//                            //Call function to get local user's timezone abbreviation as a string ("GMT+9" returns for Seoul)
//                            let localZone = self.ltzAbbrev()
//                            dateFormatter.timeZone = NSTimeZone(name: "\(localZone)")
//                            var dateString = dateFormatter.stringFromDate(date!)
//                            ////println("the local time that this happened at was \(dateString)")
//                            dateString = dateFormatter.stringFromDate(date!)
//                            
//                            self.thisChatsTimestamps.append(dateString)
//                            self.thisChatsMessages.append(object["messageText"] as! String!)
//                            self.thisChatsMessageSenders.append(object["senderObjectId"] as! String!)
//                            
//                            //println("thisChatsTimestamps array is  \(self.thisChatsTimestamps)")
//                            //println("thisChatsMessages array is  \(self.thisChatsMessages)")
//                            //println("thisChatsMessageSenders array is \(self.thisChatsMessageSenders)")
//                            
//                            
//                            
//                        }
//                        //println("thisChatsTimestamps array is  \(self.thisChatsTimestamps)")
//                        //println("thisChatsMessages array is  \(self.thisChatsMessages)")
//                        //println("thisChatsMessageSenders array is \(self.thisChatsMessageSenders)")
//                        
//                        self.chatMessages.append(self.thisChatsMessages)
//                        self.chatMessageSenders.append(self.thisChatsMessageSenders)
//                        self.chatTimestamps.append(self.thisChatsTimestamps)
//                        
//                        //println("chatMessages array is \(self.chatMessages)")
//                        //println("chatMessageSenders array is \(self.chatMessageSenders)")
//                        //println("chatTimestamps array is \(self.chatTimestamps)")
//                        
//                        self.thisChatsMessages.removeAll(keepCapacity: false)
//                        self.thisChatsMessageSenders.removeAll(keepCapacity: false)
//                        self.thisChatsTimestamps.removeAll(keepCapacity: false)
//                        
//                        //for this chatId, set the subArray to the chat messages array acquired for this chatId
//                        //keep in mind the row for each is represented by the index, not the chatId itself, but both arrays' indexes are complimentary
//                    }
//                }
            }
            //MUST BE AFTER THE FOR LOOP WITH I OR ELSE IT DOES NOT GET ALL THE CHATS!
            self.results = self.resultsObjectIds.count
            self.currResult = 0
            self.fetchResults()
            // }

        })
    }
    
    func fetchResults() {
//if the tableview is not done populating all of the chat cells
        if currResult < results {
//query the User class for the objectIds of the most recent message sender for each chat
            
            let queryF = PFUser.query()
            //chatMessageSenders[row: chatId][first column, most recent senderId]
            
            print("chatMessageSenders is \(chatMessageSenders)")
            print("currResult is \(currResult)")
            print(chatMessageSenders[currResult])
            print(chatMessageSenders[currResult][0])
            queryF!.whereKey("objectId", equalTo: self.chatMessageSenders[currResult][0])
//            let objects = queryF!.findObjects()
//            for object in objects! {
//                self.resultsNameArray.append(object.objectForKey("displayName") as! String)
//                self.resultsImageFiles.append(object.objectForKey("photo") as! PFFile)
//            }
            
            self.currResult = self.currResult + 1
            self.fetchResults()
            dispatch_async(dispatch_get_main_queue(), {
                self.resultsTable.reloadData()
                self.resumeApp()
            })
        }
     //   self.coreDataContent = true
    }
    
    
    /***********************************************************************************************
    //MARK: Setup tableview and cells for groups
    ***********************************************************************************************/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //    let numberOfRowsInSection = frc.sections?[section].numberOfObjects
    //    return numberOfRowsInSection!
        return resultsObjectIds.count
    }
    
    /*
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = frc.sections?.count
        return numberOfSections!
    }
    */

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:chatsCell = tableView.dequeueReusableCellWithIdentifier("chatsCell") as! chatsCell
        
        cell.chatNameLbl.text = chatTitles[indexPath.row]
//first term of the row describing that chat should be the most recent message
        cell.messageLbl.text = (self.chatMessages[indexPath.row][0] as String)
        cell.lastMsgTimeStamp.text = (self.chatTimestamps[indexPath.row][0] as String)
        cell.usernameLbl.text = (self.chatMessageSenders[indexPath.row][0] as String)
        if chatsParticipantsIds[indexPath.row].count > 2 {
            cell.multIcon.hidden = false
            cell.multQty.text =  "\(chatsParticipantsIds.count)"
        }
        
        resultsImageFiles[indexPath.row].getDataInBackgroundWithBlock {
            (imageData:NSData?, error:NSError?) -> Void in
            
            if error == nil {
                let image = UIImage(data: imageData!)
                cell.profileImageView.image = image
            }
        }
    
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextViewController: conversationVC = segue.destinationViewController as! conversationVC
        if(segue.identifier == "goToConversationVC2") {
            print("chatIDToFetch in chats tab is \(self.chatIdToFetch)")
            nextViewController.chatObjIdFromChatsTab = self.chatIdToFetch
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! chatsCell
        self.chatIdToFetch = self.resultsObjectIds[indexPath.row]
        self.performSegueWithIdentifier("goToConversationVC2", sender: self)
    }
    
    
/***********************************************************************************************
//MARK: Create a new chat
***********************************************************************************************/
    func addChatBtn_click() {
        let alert = UIAlertController(title: "New Chat", message: "Type the name of the chat", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {
            (action) -> Void in
            
            
            let textF = alert.textFields![0] //first field
            
            let chatObj = PFObject(className: "Chats")
            chatObj["chatParticipantIds"] = [self.userObjectID]
            chatObj["chatParticipantDisplayNames"] = [self.userDisplayName]
            chatObj["chatTitle"] = textF.text
            chatObj["adminIds"] = [self.userObjectID]
            //chatObj["adminUsernames"] = [userName]
            
            
            //instead of a simple save, we do a block in order to capture the objectId within the same transaction
            //send an initial message to the chat
            chatObj.saveInBackgroundWithBlock({
                (succeeded, error:NSError?) -> Void in
                if error == nil {
                    if let chatId = chatObj.objectId! as String! {
                        self.chatIdToFetch = chatId
                        print("check1")
                        let msgObj = PFObject(className: "Messages")
                        msgObj["chatObjectId"] = chatId
                        msgObj["chatTitle"] = textF.text
                        msgObj["senderObjectId"] = self.userObjectID
                        //        msgObj["senderUsername"] = userName
                        msgObj["messageText"] = "The group has been created: \(textF.text)"
                        msgObj.saveInBackground()
                        //and also save this chat id in the user class to say that this user has participation rights
                        let predicate = NSPredicate(format: "objectId = '"+self.userObjectID+"'")
                        let chatObj2 = PFQuery(className: "_User", predicate: predicate)
                        //                            chatObj2.findObjectsInBackgroundWithBlock({
                        //                                (objects:[AnyObject]?, error:NSError?) -> Void in
                        //                                if error == nil {
                        //                                    if let objs = objects {
                        //                                        for object in objs {
                        //                                            object.addUniqueObject(chatId, forKey: "chatObjectIds")
                        //                                            object.saveInBackground()
                        //                                        }
                        //                                    }
                        //                                    self.performSegueWithIdentifier("goToConversationVC2", sender: self)
                        //                                }
                        //                            })
                    }
                }
            })
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: {
            (action) -> Void in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
/***********************************************************************************************
//MARK: Find out what timezone the user is in and adjust timestamp/offset accordingly
***********************************************************************************************/
    func ltzAbbrev() -> String { return NSTimeZone.localTimeZone().abbreviation! }
    func ltzOffset() -> Int { return NSTimeZone.localTimeZone().secondsFromGMT }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

/***********************************************************************************************
//MARK: CODE CLOSET
***********************************************************************************************/



/*
//save wanted data for a chat to the Chat class
let context = self.context
let ent = NSEntityDescription.entityForName("Chat", inManagedObjectContext: context)
let nItemChat = Chat(entity: ent!, insertIntoManagedObjectContext: context)
nItemChat.chatObjectId = thisChatId
nItemChat.chatTitle = (object["chatTitle"] as! String!)
self.context.save(nil)

//save wanted data for a chat to the Acquaintance
let ent2 = NSEntityDescription.entityForName("Acquaintance", inManagedObjectContext: context)
let nItemAcquaintance = Acquaintance(entity: ent2!, insertIntoManagedObjectContext: context)
for (var j = 0; j < self.thisChatsParticipantsIds.count; j++) {
nItemAcquaintance.acqObjectId = self.thisChatsParticipantsIds[j]
nItemAcquaintance.acqDisplayName = self.thisChatsParticipantDisplayNames[j]
nItemAcquaintance.acqUsername = self.thisChatsAdminUsernames[j]
//as loop thru participant list occurs, set admin bool to true if objectId present in admin array
if contains(self.thisChatsAdminIds, self.thisChatsParticipantsIds[j]){
nItemAcquaintance.acqAdminBool = true
} else {
nItemAcquaintance.acqAdminBool = false
}
var queryF = PFUser.query()
queryF!.whereKey("objectId", equalTo: self.thisChatsParticipantsIds[j])
queryF?.findObjectsInBackgroundWithBlock({
(objects:[AnyObject]?, error:NSError?) -> Void in
if let objs = objects {
for object in objs {
let userImageFile = object["photo"] as! PFFile
userImageFile.getDataInBackgroundWithBlock({
(imageData:NSData?, error:NSError?) -> Void in
let image = UIImage(data: imageData!)
nItemAcquaintance.acqImage = UIImagePNGRepresentation(image)
})
}
}
})
self.context.save(nil)

}
*/



/*
if let chat = frc.objectAtIndexPath(indexPath) as? Chat {
//println("nItemChat has chat data content")
coreDataContent = true
cell.chatNameLbl.text = chat.chatTitle
// define acquaintance but not indexPath on table, for the nth participant of a chat
if chat.chatAcquaintance.count > 2 {
cell.multIcon.hidden = false
cell.multQty.text = String(chat.chatAcquaintance.count)
} else if chat.chatAcquaintance.count < 3 {
cell.multIcon.hidden = true
cell.multQty.text = ""
}
cell.profileImageView.image = UIImage(data: chat.chatAcquaintance)

//only get the latest chat message's data
for (var l = 0; l < chat.chatMessage.count; l++) {
cell.messageLbl.text = chat.chatMessage.
cell.lastMsgTimeStamp.text = chat.chatMessage.
cell.usernameLbl.text = chat.chatMessage.
}
*/


/*
//save wanted data for the messages of this chat
let context = self.context
let ent = NSEntityDescription.entityForName("Message", inManagedObjectContext: context)
let nItemMessage = Message(entity: ent!, insertIntoManagedObjectContext: context)
nItemMessage.chatObjectId = thisChatId
nItemMessage.senderObjectId = (object["senderObjectId"] as! String!)
nItemMessage.messageText = (object["messageText"] as! String!)
nItemMessage.createdAt = dateString
self.context.save(nil)
*/


/***********************************************************************************************
//MARK: Core Data Context, nItem, and newItem()
***********************************************************************************************/
/*
let context:NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!

//generic call to fetch results in the context
var frc:NSFetchedResultsController = NSFetchedResultsController()

func getFetchResultsController() -> NSFetchedResultsController {
frc = NSFetchedResultsController(fetchRequest: ListFetchRequests(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
return frc
}

//here's where we need to reference multiple classes
//in order to effectively do this we need to have the data model relationships (child/parent etc)
func ListFetchRequests() -> NSFetchRequest {
let fetchRequest = NSFetchRequest(entityName: "Chat")
//sorts list by last message sent to any chat
let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
fetchRequest.sortDescriptors = [sortDescriptor]
return fetchRequest
}

var coreDataContent:Bool = false
*/


