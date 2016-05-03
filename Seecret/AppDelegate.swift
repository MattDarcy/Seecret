//  
//  AppDelegate.swift
//  Seecret
//
//  Created by Matt D'Arcy on 8/14/15.
//  Copyright (c) 2015 Seecret. All rights reserved.
//

// Project initially created with XCode 6.4, Swift 1.2, and Parse 1.7.x
// Project migrated to Xcode 7.2, Swift 2
// Project in progress of migration to Xcode 7.3

/***********************************************************************************************
//MARK: TODO
***********************************************************************************************/
// Have a swift file with all global variables that store all programmatic strings. Then a switch case can be implemented throughout the file according to the language the user chose. This file can be really long and include every string in the app in each supported language


import UIKit
import Parse
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var chatObjIdToUpdateOutApp:NSString = ""
    var chatMessageToUpdateOutApp:NSString = ""
    
    var chatObjIdToUpdateInApp:NSString = ""
    var chatMessageToUpdateInApp:NSString = ""
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        

        
        
        Parse.setApplicationId("8ynIb1OqlcecH68bEuM1kaYHOl5TUy2F1rYjsEig", clientKey: "MbwbFx8djLqzoFow4pgwMvuT1cY1VoxODGQJuqC5")       
        
        /***********************************************************************************************
        //MARK: Required didFinishLaunchingWithOptions code for Push Notifications
        ***********************************************************************************************/
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            let preBackgroundPush = !application.respondsToSelector(Selector("backgroundRefreshStatus"))
            let oldPushHandlerOnly = !self.respondsToSelector(#selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        /***********************************************************************************************
        //MARK: Required functions for Push Notifications
        ***********************************************************************************************/
        
        // Extract the custom data from the push notification
        if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            
            // Create a pointer to the object
            chatObjIdToUpdateOutApp = notificationPayload["chatObjId"] as! NSString
            chatMessageToUpdateOutApp = notificationPayload["message"] as! NSString
            
            print("I got \(chatObjIdToUpdateOutApp) and \(chatMessageToUpdateOutApp))")
            
        }

        
        if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
            if #available(iOS 8.0, *) {
                let types:UIUserNotificationType = ([.Alert, .Sound, .Badge])
                let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
            } else {
                application.registerForRemoteNotificationTypes([.Alert, .Sound, .Badge])
            }
        }
        else {
            // Register for Push Notifications before iOS 8
            application.registerForRemoteNotificationTypes([.Alert, .Sound, .Badge])
        }
        return true
    }

    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("") { (succeeded, error) in
            if succeeded {
                print("Seecret successfully subscribed to push notifications on the broadcast channel.");
            } else {
                print("Seecret failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        
        print("userInfo is \(userInfo)")
        
        if userInfo["chatObjId"] != nil {
            chatObjIdToUpdateInApp = userInfo["chatObjId"] as! NSString
            chatMessageToUpdateInApp = userInfo["message"] as! NSString
            print("I got \(chatObjIdToUpdateInApp) and \(chatMessageToUpdateInApp)")
            NSNotificationCenter.defaultCenter().postNotificationName("getMessage", object: nil)
        }

        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

/***********************************************************************************************
//MARK: CODE CLOSET
***********************************************************************************************/


