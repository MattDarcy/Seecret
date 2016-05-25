//
//  loginVC.swift
//  Seecret
//
//  Created by Matt D'Arcy on 8/14/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//

/***********************************************************************************************
//MARK: TODO
***********************************************************************************************/
// upon login of new person, nix all core data for entire app
// have a class that just downloads all needed data in background for the entire app and store in core data. Then on each view controller it just takes from coredata and updates according to push notes.
// Consider using dictionaries. Dictionaries can hold arrays (messages, names/id's, images) and it is place-independent
// fix up global vars

var user : [Login] = []
var savedUsername:String = ""
var savedPassword:String = ""


import UIKit
import ReachabilitySwift
import CoreData

class loginVC: UIViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {

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
    //MARK: Core Data Context, nItem, and newItem()
    ***********************************************************************************************/
    let context:NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var nItem : Login? = nil
    var frc:NSFetchedResultsController = NSFetchedResultsController()
    func getFetchResultsController() -> NSFetchedResultsController {
        frc = NSFetchedResultsController(fetchRequest: ListFetchRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }
    func ListFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Login")
        //sorts list by alphabetical item
        let sortDescriptor = NSSortDescriptor(key: "username", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    var coreDataContent:Bool = false
    
    
    
    
    
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var errorMsg: UILabel!
    
    let parseBadLogin:Int = 101
    
    func preTreatView() {
        //assign for CoreData
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext
        let request = NSFetchRequest(entityName: "Login")
        var err:NSError?
        do {
            user = try context?.executeFetchRequest(request) as! [Login]
            //find out how to structure this in Swift 2
            print("The user retained in core data is \(user)")
            
        } catch let err1 as NSError {
            err = err1
        }
        if (err != nil) {
            print("Problem with loading data")
        }
        
        
        frc = getFetchResultsController()
        frc.delegate = self
        try! frc.performFetch()
        //if there is a saved username in core data, populate text box
        let loginRequest = NSFetchRequest(entityName: "Login")
        loginRequest.fetchLimit = 1
        if let user = try! context!.executeFetchRequest(loginRequest).first as? [Login] {
            print("there is data")
            //print("username is \(user.username) and password is \(user.password)")
            //usernameTxt.text = user.username
            //passwordTxt.text = user.password
        } else {
            print("there is no data")
        }

        
        
        
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        loginBtn.layer.cornerRadius = 7
        registerBtn.layer.cornerRadius = 7
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preTreatView()
    }

    
    override func viewDidAppear(animated: Bool) {
        preTreatView()
    }
    
    
    /***********************************************************************************************
    //MARK: Log in with email and password. Checks for connectivity and then login success/error
    ***********************************************************************************************/
    
    //Parse will automatically try and back-off if the connection is not made. It is best practices for networking.
    
    @IBAction func loginBtn(sender: AnyObject) {
        self.errorMsg.text = ""
        
     
        pauseApp()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {  
            
            let reachability: Reachability
            do {
                reachability = try Reachability.reachabilityForInternetConnection()
            } catch {
                print("Unable to create Reachability")
                print("internet is DEAD!!!")
                self.errorMsg.text = "No network connection..."
                return
            }
            
            
            reachability.whenReachable = { reachability in
                // this is called on a background thread, but UI updates must
                // be on the main thread, like this:
                dispatch_async(dispatch_get_main_queue()) {
                    if reachability.isReachableViaWiFi() {
                        print("Reachable via WiFi")
                    } else {
                        print("Reachable via Cellular")
                    }
                    self.errorMsg.text = ""
                }
            }
            
            reachability.whenUnreachable = { reachability in
                // this is called on a background thread, but UI updates must
                // be on the main thread, like this:
                dispatch_async(dispatch_get_main_queue()) {
                    print("Not reachable")
                    print("internet is DEAD!!!")
                    self.errorMsg.text = "No network connection..."
                }
            }
            
            do {
                try reachability.startNotifier()
            } catch {
                print("Unable to start reachability notifier")
            }
            
            PFUser.logInWithUsernameInBackground(self.usernameTxt.text!, password: self.passwordTxt.text!) {
                (user:PFUser?, logInError:NSError?) -> Void in
                
                if let errorCode = logInError?.code as Int! {
                    if errorCode == 101 {
                        self.errorMsg.text = "Incorrect Email or Password"
                    } else {
                        self.errorMsg.text = "Please report: login error \(errorCode)"
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.resumeApp()
                    })
                } else if logInError == nil{
                    reachability.stopNotifier()
                    let context = self.context
                    //check if previous core data and delete
                    //save the username and password in core data
                    let ent = NSEntityDescription.entityForName("Login", inManagedObjectContext: context)
                    let nItem2 = Login(entity: ent!, insertIntoManagedObjectContext: context)
                    nItem2.username = self.usernameTxt.text!
                    nItem2.password = self.passwordTxt.text!
                    self.coreDataContent = true
                    
                    do {
                        try context.save()
                    } catch {
                        print("problem");
                    }
                    let installation: PFInstallation = PFInstallation.currentInstallation()
                    installation["user"] = PFUser.currentUser()
                    installation.saveInBackground()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.resumeApp()
                    })
                    self.performSegueWithIdentifier("goToTabsVC", sender: self)
                }
            }

        })

    }

    /***********************************************************************************************
    //MARK: Close keyboard if enter key pressed
    ***********************************************************************************************/
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.usernameTxt.resignFirstResponder()
        self.passwordTxt.resignFirstResponder()
        return true
    }
    
    /***********************************************************************************************
    //MARK: Remove the keyboard when user taps blank space
    ***********************************************************************************************/
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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


