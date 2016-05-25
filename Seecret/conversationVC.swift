//
//  conversationVC.swift
//  Seecret
//
//  Created by Matt D'Arcy on 8/18/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//

/***********************************************************************************************
//MARK: TODO
***********************************************************************************************/


import UIKit
import Bolts

var userDisplayName = ""

var chatExistsFlag = false


class conversationVC: UIViewController, UIScrollViewDelegate, UITextViewDelegate {

    
    @IBOutlet weak var angryBtn: UIButton!
    @IBOutlet weak var happyBtn: UIButton!
    @IBOutlet weak var sadBtn: UIButton!
    
    @IBOutlet weak var angryQty: UILabel!
    @IBOutlet weak var happyQty: UILabel!
    @IBOutlet weak var sadQty: UILabel!
    
    @IBOutlet var resultsScrollView: UIScrollView!
    @IBOutlet var frameMessageView: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet var messageTextView: UITextView!
    
    //@IBOutlet weak var blockBtn: UIBarButtonItem!

    var otherName = ""
    var otherUserId = ""
    var otherDisplayName = ""
    
    var chatObjIdFromChatsTab:String = ""
    var chatObjIdFromSeecretsTab:String = ""
    var userAccountStatus:String = ""
    var userGrantedSeecretAccess:Bool = false
    var chatObjId = ""
    
    var scrollViewOriginalY:CGFloat = 0
    var frameMessageOriginalY:CGFloat = 0
    
    let mLbl = UILabel(frame: CGRectMake(5,8,200,20))
    
    var messageX:CGFloat = 37.0
    var messageY:CGFloat = 26.0
    var frameX:CGFloat = 32.0
    var frameY:CGFloat = 21.0
    var imgX:CGFloat = 3
    var imgY:CGFloat = 3
    
    var chatParticipantIdsArray = [String]()
    var chatParticipantDisplayNames = [String]()
    var senderDisplaynameArray = [String]()

    var messageArray = [String]()
    var senderArray = [String]()
    
    var myImg:UIImage? = UIImage()
    var otherImg:UIImage? = UIImage()
    var imgArray:[UIImage]? = [UIImage]()
    
    var resultsImageFiles = [PFFile]()
    var resultsImageFiles2 = [PFFile]()
    
    var isBlocked = false
    
    var userParticipantType:String = ""
    
    var blockBtn = UIBarButtonItem()
    var reportBtn = UIBarButtonItem()

    //75 names from indices 0-->74 to display instead of the actual displaynames if the user is the seecret viewer
    var seecretNameArray = ["cat","mouse","wolf","ragamuffin","rapunzel","hansel","gretel","white snake","coal","bean","fisherman","valiant little tailor","riddle","mouse","sausage","raven","singing bone","golden hair","hans","wishing-table","thumbling","elf","foundling-bird","juniper tree","old sultan","swan","little briar-rose","king thrushbeard","knapsack","hat","horn","rumpelstiltskin","sweetheart roland","golden bird","frederick","catherine","queen bee","golden goose","hare's bride","jorinde","joringel","gossip wolf","water nixie","little hen","springing lark","young giant","old hildebrand","water of life","doctor know-all","spirit in the bottle","bearskin","willow wren","sweet porridge","wise folks","paddock","hans my hedgehog","skillful huntsman","blue light","donkey cabbages","ferdinand the faithful","iron stove","lazy spinner","pif-paf-poltrie","fair katrinelje","knoist","the lambkin","the turnip","the star money","rose-red","wise servant","joy and sorrow","master pfreim","sea-hare","old rinkrank","snow white"]



    
    @IBAction func addAngry(sender: AnyObject) {
        var angry:Int = Int(angryQty.text!)!
        angry++
        angryQty.text = String(stringInterpolationSegment: angry)
    }
    
    @IBAction func addHappy(sender: AnyObject) {
        var happy:Int = Int(happyQty.text!)!
        happy++
        happyQty.text = String(stringInterpolationSegment: happy)
    }
    
    
    @IBAction func addSad(sender: AnyObject) {
        var sad:Int = Int(sadQty.text!)!
        sad++
        sadQty.text = String(stringInterpolationSegment: sad)
    }
    
    
    
    
    func addBurgerBtn() {
        
        self.angryBtn.layer.zPosition = 40
        self.happyBtn.layer.zPosition = 40
        self.sadBtn.layer.zPosition = 40
        self.angryQty.layer.zPosition = 41
        self.happyQty.layer.zPosition = 41
        self.sadQty.layer.zPosition = 41
        
/***********************************************************************************************
//MARK: Add hamburger menu button
***********************************************************************************************/
        let button:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "hamburger.png"), style: UIBarButtonItemStyle.Plain, target:self, action: "burgerBtnPress")
        
        self.navigationItem.rightBarButtonItem = button
        
        let backItem = UIBarButtonItem(title: "", style: .Bordered, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }

    func burgerBtnPress() {
        self.performSegueWithIdentifier("goToChatParticipants", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextViewController: chatParticipantsVC = segue.destinationViewController as! chatParticipantsVC
        if(segue.identifier == "goToChatParticipants") {
            //println("chatIDToFetch is \(self.chatIdToFetch)")
            nextViewController.thisChatId = chatObjId
            nextViewController.userDisplayName = userDisplayName
            print("the displayNamesArray is \(self.chatParticipantDisplayNames)")
            nextViewController.chatParticipantDisplayNameArray = self.chatParticipantDisplayNames
            nextViewController.userParticipantType = userParticipantType
            nextViewController.fromConversation = true
        }
    }
    
/***********************************************************************************************
//MARK: UIActivity Spinner
***********************************************************************************************/
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    func pauseApp() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
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
//MARK: Retrieve needed user/other data
***********************************************************************************************/
    func getUserData() {
        var predicate = NSPredicate(format: "objectId = '"+userObjectID+"'")
        var query = PFQuery(className: "_User", predicate: predicate)
        query.findObjectsInBackgroundWithBlock({
            (objects:[AnyObject]?, error:NSError?) -> Void in
            if let objs = objects {
                for object in objs {
                    userDisplayName = (object["displayName"] as! String!)
                }
                
                
                //this needs to be done for an array and needs to be handleable for sizes of 0 to the max size of a chat minus the currentUser
                //this is currently done for just the other person who was the friend in the friend list
                predicate = NSPredicate(format: "objectId = '"+self.otherUserId+"'")
                query = PFQuery(className: "_User", predicate: predicate)
                query.findObjectsInBackgroundWithBlock({
                    (objects:[AnyObject]?, error:NSError?) -> Void in
                    if let objs = objects {
                        for object in objs {
                            self.otherDisplayName = (object.objectForKey("displayName") as! String)
                            self.otherName = (object.objectForKey("username") as! String)
                        }


                        
                
/***********************************************************************************************
//MARK: When entering 1:1 chat, see if exists already. If not, create.
***********************************************************************************************/
                        //we will come in from friends tab with 2 usernames. if otherName is not blank.
                        //we will come in from chats tab with chatObjId ONLY IF EXISTS!
                        //if came from friends tab, otherName not blank, search by the two names in the chat.
                        //if came from chats tab, othername blank so search by the objectId
                
                        print("chatObjIdFromChatsTab is \(self.chatObjIdFromChatsTab)")
                        print("chatObjIdFromSeecretsTab is \(self.chatObjIdFromSeecretsTab)")
                        print("otherUserId is \(self.otherUserId)")
                
                        query = PFQuery(className: "Chats")
                        if self.chatObjIdFromChatsTab == "" && self.chatObjIdFromSeecretsTab == "" && self.otherUserId != "" {
                            print("querying for otherName")
                            print("userId is \(userObjectID) and otherUserID is \(self.otherUserId)")
                            query.whereKey("chatParticipantIds", containsAllObjectsInArray:[userObjectID,self.otherUserId])
                        } else if self.chatObjIdFromChatsTab != "" && self.chatObjIdFromSeecretsTab == "" && self.otherUserId == "" {
                            print("querying for objId from chats tab")
                            self.chatObjId = self.chatObjIdFromChatsTab
                            print("chatObjIdFromChatsTab is \(self.chatObjIdFromChatsTab)")
                            query.whereKey("objectId", equalTo: self.chatObjIdFromChatsTab)
                        } else if self.chatObjIdFromSeecretsTab != "" && self.chatObjIdFromChatsTab == "" && self.otherUserId == "" {
                            print("querying for objId from seecrets tab")
                            self.chatObjId = self.chatObjIdFromSeecretsTab
                            query.whereKey("objectId", equalTo: self.chatObjIdFromSeecretsTab)
                        }
                        query.findObjectsInBackgroundWithBlock {
                            (objects:[AnyObject]?, error:NSError?) -> Void in
                            if let test = objects {
                                //println("objects is \(test)")
                                if test.count == 0 {
                                    print("chat did not previously exist")
                                    let chatObj = PFObject(className: "Chats")
                                    chatObj["chatParticipantIds"] = [userObjectID, self.otherUserId]
                                    self.chatParticipantIdsArray = [userObjectID, self.otherUserId]
                                    chatObj["chatParticipantDisplayNames"] = [userDisplayName, self.otherDisplayName]
                                    self.chatParticipantDisplayNames = [userDisplayName, self.otherDisplayName]
                                    chatObj["chatTitle"] = "\(userDisplayName), \(self.otherDisplayName)"
                                    chatObj["adminIds"] = [userObjectID, self.otherUserId]
                                    chatObj["adminUsernames"] = [userName, self.otherName]
                                    chatObj.saveInBackgroundWithBlock({
                                        (succeeded, error:NSError?) -> Void in
                                        if error == nil {
                                            if let chatId = chatObj.objectId! as String! {
                                                self.chatObjId = chatId
                                                predicate = NSPredicate(format: "objectId = '"+userObjectID+"'")
                                                let chatObj2 = PFQuery(className: "_User", predicate: predicate)
                                                chatObj2.findObjectsInBackgroundWithBlock({
                                                    (objects:[AnyObject]?, error:NSError?) -> Void in
                                                    if error == nil {
                                                        if let objs = objects {
                                                            for object in objs {
                                                                object.addUniqueObject(self.chatObjId, forKey: "chatObjectIds")
                                                                object.saveInBackgroundWithBlock({
                                                                    (succeeded, error:NSError?) -> Void in
                                                                    let msgObj = PFObject(className: "Messages")
                                                                    msgObj["chatObjectId"] = self.chatObjId
                                                                    msgObj["chatTitle"] = "\(userDisplayName), \(self.otherDisplayName)"
                                                                    msgObj["senderObjectId"] = userObjectID
                                                                    msgObj["senderUsername"] = userName
                                                                    msgObj["senderDisplayName"] = userDisplayName
                                                                    msgObj["messageText"] = "Chat has been created..."
                                                                    msgObj.saveInBackgroundWithBlock({
                                                                        (succeeded, error:NSError?) -> Void in
                                                                        self.getProfileImages()
                                                                        //self.refreshResults()
                                                                    })
                                                                })
                                                            }
                                                        }
                                                    }
                                                })
                                            }
                                        }
                                    })
                                } else if test.count > 0 {
                                    print("chat exists already")
                                    for object in test {
                                        self.chatParticipantDisplayNames = (object.objectForKey("chatParticipantDisplayNames") as! [String])
                                        self.chatParticipantIdsArray = (object.objectForKey("chatParticipantIds") as! [String])
                                        print("the displaynamesArray is \(self.chatParticipantDisplayNames)")
                                    }
                                    if (self.otherUserId != "") {
                                        query = PFQuery(className: "Chats")
                                        query.whereKey("chatParticipantIds", containsAllObjectsInArray:[userObjectID,self.otherUserId])
                                        //make sure this is ok to be getting based on the 2 people all the time chat exists. I think it's not.
                                        //then when querying for the chatObjId get the participants id's and displaynames and put into the 2 arrays.
                                        
                                        query.findObjectsInBackgroundWithBlock({
                                            (objects:[AnyObject]?, error:NSError?) -> Void in
                                            if let objs = objects {
                                                for object in objs {
                                                    self.chatObjId = object.objectId as String!
                                                    print("I got the objectId \(self.chatObjId)")
                                                }
                                            }
                                        })
                                    }
                                    print("check1")
                                    
                                    self.getProfileImages()
                                    //self.refreshResults()
                                }
                            }
                        }
                    }
                })
            }
        })
    }

/***********************************************************************************************
//MARK: If the user is a seecretViewer replace names with one of the default 75
***********************************************************************************************/
    
    func replaceSeecretNames() {
    
        
        
        
        if userParticipantType == "seecretViewer" {
            for (var s = 0; s < self.chatParticipantIdsArray.count; s++) {
                //println("self.chatPart.count is \(self.chatParticipantIdsArray.count)")
                let randomNameIndex = Int(arc4random_uniform(UInt32(self.seecretNameArray.count-1)))
                //println("the random number is \(randomNameIndex) and the seecretName is \(self.seecretNameArray[randomNameIndex])")
                //println("seecretNameCount is \(self.seecretNameArray.count)")
                let uniqueDisplayNameCheckArray = Array(self.chatParticipantDisplayNames)
                self.chatParticipantDisplayNames[s] = self.seecretNameArray[randomNameIndex]
                //println("chatParticipantDisplayNames is now \(self.chatParticipantDisplayNames)")
                //println("uniqyeDisplayNameCheckArray is now \(uniqueDisplayNameCheckArray)")
                let uniqueReplaceName = uniqueDisplayNameCheckArray[s]
                //println("uniqueReplaceName is now \(uniqueReplaceName)")
                //println("the amount of messages is \(self.senderDisplaynameArray.count)")
                //println("the sender array is \(self.senderDisplaynameArray)")
                for (var y = 0; y < self.senderDisplaynameArray.count; y++) {
                    print("the senderDisplayNameArray is \(self.senderDisplaynameArray)")
                    print("uniqueReplaceName is now \(uniqueReplaceName)")
                    //uniqueReplaceName needs to be equal to Matt
                    if self.senderDisplaynameArray[y] == uniqueReplaceName {
                        //println("senderDisplayNameArray is \(self.senderDisplaynameArray)")
                        //println("the name to be reassigned is term \(y) and it is \(self.senderDisplaynameArray[y])")
                        //println("it will be changed to new name: \(self.seecretNameArray[randomNameIndex])")
                        self.senderDisplaynameArray[y] = self.seecretNameArray[randomNameIndex]
                        //println("now the senderDisplayNameArray is \(self.senderDisplaynameArray)")
                    }
                }
                
                /*
                println("s is \(s) and self.chatPart.count is \(self.chatParticipantIdsArray.count)")
                println("count is \(self.chatParticipantIdsArray.count)")
                println("randomnum chosen is \(randomNameIndex) and the new name is \(seecretNameArray[randomNameIndex])")
                println("chatParticipantDisplayNames is now \(self.chatParticipantDisplayNames)")
                println("senderDisplaynameArray is \(self.senderDisplaynameArray)")
                println("s is \(s)")
                println("array is \(uniqueDisplayNameCheckArray)")
                println("the displaynames array is now \(self.chatParticipantDisplayNames)")
                */
                
               /*
                
                let uniqueDisplayNameCheckArray = Array(Set(self.senderDisplaynameArray))
                println("the uniqueDisplayNameCheckArray is \(uniqueDisplayNameCheckArray)")
                
                for (var x = 0; x < uniqueDisplayNameCheckArray.count; x++) {
                    let uniqueReplaceName = uniqueDisplayNameCheckArray[x]
                    println("replacing for the name \(uniqueReplaceName)")
                    for (var y = 0; y < self.senderDisplaynameArray.count; y++) {
                        if self.senderDisplaynameArray[y] == uniqueReplaceName {
                            self.senderDisplaynameArray[y] = self.seecretNameArray[randomNameIndex]
                        }
                    }
                }
                */
                //self.senderDisplaynameArray[s] = self.seecretNameArray[randomNameIndex]
            }
        }
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        addBurgerBtn()
        //identify what kind of chat participant the current user is in this chat.
        print("userParticipantType is \(userParticipantType)")
        

        
        
        
        scrollViewOriginalY = self.resultsScrollView.frame.origin.y
        frameMessageOriginalY = self.frameMessageView.frame.origin.y
        
        //self.title = otherDisplayName
        
        mLbl.text = "Type a message..."
        mLbl.backgroundColor = UIColor.clearColor()
        mLbl.textColor = UIColor.lightGrayColor()
        messageTextView.addSubview(mLbl)
        
/***********************************************************************************************
//MARK: Make way for keyboard (1)
***********************************************************************************************/
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getMessageFunc", name: "getMessage", object: nil)
        let tapScrollViewGesture = UITapGestureRecognizer(target: self, action: "didTapScrollView")
        tapScrollViewGesture.numberOfTapsRequired = 1
        resultsScrollView.addGestureRecognizer(tapScrollViewGesture)
        
        //report and block button added to nav controller
        //blockBtn = UIBarButtonItem(title: "Block", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("blockBtn_click"))
        //reportBtn = UIBarButtonItem(title: "Report", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("reportBtn_click"))
        //var buttonArray = NSArray(objects: blockBtn, reportBtn)
        //self.navigationItem.rightBarButtonItems = buttonArray as [AnyObject]
        //self.navigationItem.rightBarButtonItems = buttonArray as [AnyObject]
        
        pauseApp()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.getUserData()
        })
        
    }
    
    func getMessageFunc() {
        refreshResults()
    }
    
    
/***********************************************************************************************
//MARK: Make way for keyboard (2)
***********************************************************************************************/
    func keyboardWasShown(notification:NSNotification) {
        
        let dict:NSDictionary = notification.userInfo!
        let s:NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let rect:CGRect = s.CGRectValue()
        
        UIView.animateWithDuration(0.01, delay: 0, options: .CurveLinear, animations: {
            
            self.resultsScrollView.frame.origin.y = self.scrollViewOriginalY - rect.height
            self.frameMessageView.frame.origin.y = self.frameMessageOriginalY - rect.height
            
            let bottomOffset:CGPoint = CGPointMake(0, self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height)
            self.resultsScrollView.setContentOffset(bottomOffset, animated: false)
            
            }, completion: {
                (finished:Bool) in
                
        })
        
    }
    
    func keyboardWillHide(notification:NSNotification) {
        
        let dict:NSDictionary = notification.userInfo!
        let s:NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let rect:CGRect = s.CGRectValue()
        
        UIView.animateWithDuration(0.01, delay: 0, options: .CurveLinear, animations: {
            
            self.resultsScrollView.frame.origin.y = self.scrollViewOriginalY
            self.frameMessageView.frame.origin.y = self.frameMessageOriginalY
            
            let bottomOffset:CGPoint = CGPointMake(0, self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height)
            self.resultsScrollView.setContentOffset(bottomOffset, animated: false)
            
            }, completion: {
                (finished:Bool) in
                
        })
        
        
        
        /*
        println("chatParticipantIdsArray is \(chatParticipantIdsArray)")
        println("chatParticipantDisplayNames is \(chatParticipantDisplayNames)")
        println("senderArray is \(senderArray)")
        println("senderDisplaynameArray is \(senderDisplaynameArray) ")
        println("messageArray is \(messageArray)")
        */
        
    }

/***********************************************************************************************
//MARK: Hide label once some text is entered, show once text is gone
***********************************************************************************************/
    func textViewDidChange(textView: UITextView) {
        if !messageTextView.hasText() {
            self.mLbl.hidden = false
            self.sendBtn.hidden = true
        } else {
            self.mLbl.hidden = true
            self.sendBtn.hidden = false
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if !messageTextView.hasText() {
            self.mLbl.hidden = false
        }
    }
    
    
/***********************************************************************************************
//MARK: Hide keyboard if tap scrollview
***********************************************************************************************/
    func didTapScrollView() {
        self.view.endEditing(true)
    }
    
    func getProfileImages() {
        /***********************************************************************************************
        //MARK: Get profile images
        ***********************************************************************************************/
        
        if userParticipantType == "seecretViewer" {
            self.otherImg = UIImage(named: "profileIcon")
            self.refreshResults()
        } else {
            
            let query = PFQuery(className: "_User")
            query.whereKey("username", equalTo: userName)
            query.findObjectsInBackgroundWithBlock {
                (objects:[AnyObject]?, error:NSError?) -> Void in
                self.resultsImageFiles.removeAll(keepCapacity: false)
                
                for object in objects! {
                    self.resultsImageFiles.append(object["photo"] as! PFFile)
                    self.resultsImageFiles[0].getDataInBackgroundWithBlock {
                        (imageData:NSData?, error:NSError?) -> Void in
                        
                        if error == nil {
                            self.myImg = UIImage(data: imageData!)
                            //var query2 = PFQuery(className: "_User")
                            let query2 = PFUser.query()
                            
                            //set up if statements to query related to othername if coming from friends tab, otherwise getting the images of each participant if coming from chats/seecrets tab
                            
                            print("chatParticipantIdsArray is \(self.chatParticipantIdsArray)")
                            
                            for (var u = 0; u < self.chatParticipantIdsArray.count; u++) {
                                query2!.whereKey("objectId", equalTo: self.chatParticipantIdsArray[u])
                                query2!.findObjectsInBackgroundWithBlock({
                                    (objects2:[AnyObject]?, error:NSError?) -> Void in
                                    self.resultsImageFiles2.removeAll(keepCapacity: false)
                                    for object in objects2! {
                                        self.resultsImageFiles2.append(object["photo"] as! PFFile)
                                        self.resultsImageFiles2[0].getDataInBackgroundWithBlock {
                                            (imageData:NSData?, error:NSError?) -> Void in
                                            
                                            if error == nil {
                                                self.otherImg = UIImage(data: imageData!)
                                                self.imgArray?.append(UIImage(data: imageData!)!)
                                                
                                            }
                                        }
                                    }
                                    self.refreshResults()
                                })
                            }
                            print("imgArray count is \(self.imgArray?.count)")
                        }
                    }
                }
            }
        }
    }
    

    override func viewDidAppear(animated: Bool) {
        //all messages start poisitioning at the end of the scrollview (Kakao does not do this)
        let bottomOffset:CGPoint = CGPointMake(0,self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height)
        self.resultsScrollView.setContentOffset(bottomOffset, animated: false)
    }
    

    
    func refreshResults() {
        
        
            
            let theWidth = self.view.frame.size.width
            let theHeight = self.view.frame.size.height
            
            self.messageX = 37.0
            self.messageY = 26.0
            self.frameX = 32.0
            self.frameY = 21.0
            self.imgX = 3
            self.imgY = 3
            
            /***********************************************************************************************
            //MARK: Clear contents of query arrays to avoid duplicating info on refreshes
            ***********************************************************************************************/
            self.messageArray.removeAll(keepCapacity: false)
            self.senderArray.removeAll(keepCapacity: false)
            self.senderDisplaynameArray.removeAll(keepCapacity: false)
            //chatParticipantIdsArray.removeAll(keepCapacity: false)
            //chatParticipantDisplayNames.removeAll(keepCapacity: false)
            
            /***********************************************************************************************
            //MARK: Get messages and metadata from parse, display in chat view
            ***********************************************************************************************/
            print("going to fetch results for chatID \(self.chatObjId)")
            let innerP1 = NSPredicate(format: "chatObjectId = %@",self.chatObjId)
            let innerQ1:PFQuery = PFQuery(className: "Messages",predicate: innerP1)
            
            let query = PFQuery.orQueryWithSubqueries([innerQ1])
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackgroundWithBlock {
                (objects:[AnyObject]?, error:NSError?) -> Void in
                
                if error == nil {
                    if let objs = objects {
                        for object in objs {
                            self.senderArray.append(object.objectForKey("senderUsername") as! String)
                            self.senderDisplaynameArray.append(object.objectForKey("senderDisplayName") as! String)
                            self.messageArray.append(object.objectForKey("messageText") as! String)
                        }
                    }
                    
                    //empty what we have added to the scrollview
                    for subView in self.resultsScrollView.subviews {
                        subView.removeFromSuperview()
                        
                    }
                    
                    self.replaceSeecretNames()
                    
                    for var i = 0; i <= self.messageArray.count-1; i++ {
                        
                        if self.senderArray[i] == userName {
                            
                            //the blue color is #3BB3E6
                            //the orange color is #FBCB55
                            
                            
                            //display the user's displayname
                            let userDisplaynameLbl:UILabel = UILabel()
                            userDisplaynameLbl.frame = CGRectMake(0, 0, self.resultsScrollView.frame.size.width-94, CGFloat.max)
                            //userDisplaynameLbl.backgroundColor = UIColor.blueColor()
                            userDisplaynameLbl.textAlignment = NSTextAlignment.Right
                            userDisplaynameLbl.numberOfLines = 1
                            userDisplaynameLbl.font = UIFont(name: "Helvetica Neuse" , size: 14)
                            userDisplaynameLbl.text = self.senderDisplaynameArray[i]
                            userDisplaynameLbl.sizeToFit()
                            userDisplaynameLbl.layer.zPosition = 20
                            userDisplaynameLbl.frame.origin.x = (self.resultsScrollView.frame.size.width - self.messageX) - userDisplaynameLbl.frame.size.width
                            userDisplaynameLbl.frame.origin.y = self.messageY - 25
                            self.resultsScrollView.addSubview(userDisplaynameLbl)
                            
                            
                            //display the message from this user
                            let messageLbl:UILabel = UILabel()
                            messageLbl.frame = CGRectMake(0, 0, self.resultsScrollView.frame.size.width-94, CGFloat.max)
                            //messageLbl.backgroundColor = UIColor.blueColor()
                            //messageLbl.backgroundColor = UIColor(netHex: 0x3BB3E6)
                            print("i is \(i)")
                            if (i % 2 > 0) {
                                messageLbl.backgroundColor = UIColor(netHex: 0xFBCB55)
                            } else {
                                messageLbl.backgroundColor = UIColor(netHex: 0x3BB3E6)
                            }
                            messageLbl.lineBreakMode = NSLineBreakMode.ByWordWrapping
                            messageLbl.textAlignment = NSTextAlignment.Left
                            messageLbl.numberOfLines = 0
                            messageLbl.font = UIFont(name: "Helvetica Neuse" , size: 17)
                            //messageLbl.textColor = UIColor.whiteColor()
                            messageLbl.textColor = UIColor.blackColor()
                            messageLbl.text = self.messageArray[i]
                            messageLbl.sizeToFit()
                            messageLbl.layer.zPosition = 20
                            messageLbl.frame.origin.x = (self.resultsScrollView.frame.size.width - self.messageX) - messageLbl.frame.size.width - 5
                            messageLbl.frame.origin.y = self.messageY
                            self.resultsScrollView.addSubview(messageLbl)
                            self.messageY += messageLbl.frame.size.height + 30
                            
                            //format a nice chat bubble for the text label
                            let frameLbl:UILabel = UILabel()
                            frameLbl.frame.size = CGSizeMake(messageLbl.frame.size.width + 10, messageLbl.frame.size.height + 10)
                            frameLbl.frame.origin.x = (self.resultsScrollView.frame.size.width - self.frameX) - frameLbl.frame.size.width - 5
                            frameLbl.frame.origin.y = self.frameY
                            //frameLbl.backgroundColor = UIColor.blueColor()
                            //frameLbl.backgroundColor = UIColor(netHex: 0x3BB3E6)
                            print("i is \(i)")
                            if (i % 2 > 0) {
                                frameLbl.backgroundColor = UIColor(netHex: 0xFBCB55)
                            } else {
                                frameLbl.backgroundColor = UIColor(netHex: 0x3BB3E6)
                            }
                            frameLbl.layer.masksToBounds = true
                            frameLbl.layer.cornerRadius = 10
                            self.resultsScrollView.addSubview(frameLbl)
                            self.frameY += frameLbl.frame.size.height + 20
                            
                            //display user's image with their message
                            let img:UIImageView = UIImageView()
                            if self.userParticipantType == "seecretViewer" {
                                img.image = UIImage(named: "profileIcon")
                            } else {
                                img.image = self.myImg
                            }
                            img.frame.size = CGSizeMake(34, 34)
                            img.frame.origin.x = (self.resultsScrollView.frame.size.width - self.imgX) - img.frame.size.width
                            img.frame.origin.y = self.imgY
                            img.layer.zPosition = 30
                            img.layer.cornerRadius = img.frame.size.width/2
                            img.clipsToBounds = true
                            self.resultsScrollView.addSubview(img)
                            self.imgY += frameLbl.frame.size.height + 20
                            
                            
                            self.resultsScrollView.contentSize = CGSizeMake(theWidth, self.messageY)
                            
                        } else {
                            //do the same for the other person
                            
                            let otherUserDisplaynameLbl:UILabel = UILabel()
                            otherUserDisplaynameLbl.frame = CGRectMake(0, 0, self.resultsScrollView.frame.size.width-94, CGFloat.max)
                            otherUserDisplaynameLbl.textAlignment = NSTextAlignment.Left
                            otherUserDisplaynameLbl.numberOfLines = 1
                            otherUserDisplaynameLbl.font = UIFont(name: "Helvetica Neuse" , size: 14)
                            otherUserDisplaynameLbl.text = self.senderDisplaynameArray[i]
                            //otherUserDisplaynameLbl.backgroundColor = UIColor.blueColor()
                            otherUserDisplaynameLbl.sizeToFit()
                            otherUserDisplaynameLbl.layer.zPosition = 20
                            otherUserDisplaynameLbl.frame.origin.x = self.messageX + 6.5
                            otherUserDisplaynameLbl.frame.origin.y = self.messageY - 25
                            self.resultsScrollView.addSubview(otherUserDisplaynameLbl)
                            
                            
                            
                            let messageLbl:UILabel = UILabel()
                            messageLbl.frame = CGRectMake(0, 0, self.resultsScrollView.frame.size.width-94, CGFloat.max)
                            //messageLbl.backgroundColor = UIColor.groupTableViewBackgroundColor()
                            print("i is \(i)")
                            if (i % 2 > 0) {
                                messageLbl.backgroundColor = UIColor(netHex: 0xFBCB55)
                            } else {
                                messageLbl.backgroundColor = UIColor(netHex: 0x3BB3E6)
                            }
                            
                            messageLbl.lineBreakMode = NSLineBreakMode.ByWordWrapping
                            messageLbl.textAlignment = NSTextAlignment.Left
                            messageLbl.numberOfLines = 0
                            messageLbl.font = UIFont(name: "Helvetica Neuse" , size: 17)
                            //messageLbl.textColor = UIColor.blackColor()
                            messageLbl.textColor = UIColor.blackColor()
                            messageLbl.text = self.messageArray[i]
                            messageLbl.sizeToFit()
                            messageLbl.layer.zPosition = 20
                            messageLbl.frame.origin.x = self.messageX + 6.5
                            messageLbl.frame.origin.y = self.messageY
                            self.resultsScrollView.addSubview(messageLbl)
                            self.messageY += messageLbl.frame.size.height + 30
                            let frameLbl:UILabel = UILabel()
                            frameLbl.frame = CGRectMake(self.frameX,self.frameY,messageLbl.frame.size.width + 10, messageLbl.frame.size.height + 10)
                            //frameLbl.backgroundColor = UIColor.groupTableViewBackgroundColor()
                            if (i % 2 > 0) {
                                frameLbl.backgroundColor = UIColor(netHex: 0xFBCB55)
                            } else {
                                frameLbl.backgroundColor = UIColor(netHex: 0x3BB3E6)
                            }
                            //frameLbl.backgroundColor = UIColor(netHex: 0xFBCB55)
                            frameLbl.frame.origin.x = self.messageX + 2
                            frameLbl.layer.masksToBounds = true
                            frameLbl.layer.cornerRadius = 10
                            self.resultsScrollView.addSubview(frameLbl)
                            self.frameY += frameLbl.frame.size.height + 20
                            let img:UIImageView = UIImageView()
                            img.image = self.otherImg
                            img.frame = CGRectMake(self.imgX, self.imgY, 34, 34)
                            img.layer.zPosition = 30
                            img.layer.cornerRadius = img.frame.size.width/2
                            img.clipsToBounds = true
                            self.resultsScrollView.addSubview(img)
                            self.imgY += frameLbl.frame.size.height + 20
                            self.resultsScrollView.contentSize = CGSizeMake(theWidth, self.messageY)
                        }
                        //all messages start poisitioning at the end of the scrollview (Kakao does not do this)
                        let bottomOffset:CGPoint = CGPointMake(0,self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height)
                        self.resultsScrollView.setContentOffset(bottomOffset, animated: false)
   
                    }
                    
                }
              
                dispatch_async(dispatch_get_main_queue(), {
                    self.resumeApp()
                })
                
            } 
        
    }
    
/***********************************************************************************************
//MARK: Send message
***********************************************************************************************/
    @IBAction func sendBtn_click(sender: AnyObject) {
        if isBlocked == true {
            print("you are blocked")
            messageTextView.text = "You are blocked."
            return //blocked, so do not send anything
        }
        
        if blockBtn.title == "Unblock" {
            print("you have blocked this user!! unblock to send message")
            messageTextView.text = "Unblock to send message..."
            return //we don't want to run any more code, exit function
        }

        if userParticipantType == "seecretViewer" && userAccountStatus == "free" {
            messageTextView.text = "Upgrade to chat!"
        } else if userParticipantType == "seecretViewer" && userAccountStatus == "premium" && userGrantedSeecretAccess == false{
            self.messageTextView.text = "Ask to join!"
        } else {
        
            if messageTextView.text == "" {
            } else {
                let messageDBTable = PFObject(className: "Messages")
                messageDBTable["chatObjectId"] = chatObjId
                messageDBTable["chatTitle"] = "\(userDisplayName), \(otherDisplayName)"
                messageDBTable["senderObjectId"] = userObjectID
                messageDBTable["senderUsername"] = userName
                messageDBTable["senderDisplayName"] = userDisplayName
                messageDBTable["messageText"] = self.messageTextView.text
                let saveMessageForPush = self.messageTextView.text
                self.messageTextView.text = ""
                self.sendBtn.hidden = true
                self.mLbl.hidden = false
                messageDBTable.saveInBackgroundWithBlock {
                    (success:Bool, error:NSError?) -> Void in
                    if success == true {
                        
                        
                        //needs to be done for all others not just otherName
                        let uQuery:PFQuery = PFUser.query()!
                        uQuery.whereKey("username", equalTo: self.otherName)
                        
                        let pushQuery:PFQuery = PFInstallation.query()!
                        pushQuery.whereKey("user", matchesQuery: uQuery)
                        
                        let pushData = [
                            "alert" : "New message: \(saveMessageForPush)",
                            "chatObjId" : "\(self.chatObjId)",
                            "message" : "\(saveMessageForPush)"
                        ]
                        
                        let push:PFPush = PFPush()
                        push.setQuery(pushQuery)
                        push.setData(pushData)
                        push.sendPushInBackground()
                        print("push notification sent")
                        
                        
                        
                        
                        print("message sent")
                        self.refreshResults()
                    }
                }
            }
        }
    }
    
/***********************************************************************************************
//MARK: Block and unblock someone else
***********************************************************************************************/
    func blockBtn_click() {
        if blockBtn.title == "Block" {
            //add record to parse class to block otherUser
            let addBlock = PFObject(className: "Block")
            addBlock.setObject(userName, forKey: "user")
            addBlock.setObject(otherName, forKey: "blocked")
            addBlock.saveInBackground()
            self.blockBtn.title = "Unblock"
        } else {
            //add record to parse class to unblock otherUser
            let query:PFQuery = PFQuery(className: "Block")
            query.whereKey("user", equalTo: userName)
            query.whereKey("blocked", equalTo: otherName)
            query.findObjectsInBackgroundWithBlock({
                (objects:[AnyObject]?, error:NSError?) -> Void in
                for object in objects! {
                    object.deleteInBackground()
                }
            })
            self.blockBtn.title = "Block"
            mLbl.text = "Type a message..."
            messageTextView.text = ""
        }
    }
    
/***********************************************************************************************
//MARK: Report user - necessary for App Store
**********************************************************************************************/
    func reportBtn_click() {
        let addReport = PFObject(className: "Report")
        addReport.setObject(userName, forKey: "user")
        addReport.setObject(otherName, forKey: "reported")
        addReport.saveInBackground()
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}


/***********************************************************************************************
//MARK: Custom color extension
**********************************************************************************************/
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

/***********************************************************************************************
//MARK: CODE CLOSET
***********************************************************************************************/

