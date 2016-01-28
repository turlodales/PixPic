      //
//  AppDelegate.swift
//  P-effect
//
//  Created by Jack Lapin on 14.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
   
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        User.registerSubclass()
        Parse.enableLocalDatastore()
        Parse.setApplicationId(Constants.ParseApplicationId.AppID, clientKey: Constants.ParseApplicationId.ClientKey)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        let buttonTitlePosition = Constants.BackButtonTitle.HideTitlePosition
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(buttonTitlePosition, forBarMetrics: .Default)

        Router.sharedRouter().onStart(true)
        
        Fabric.with([Crashlytics.self])
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert,.Badge,.Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        if application.applicationState != UIApplicationState.Background {
            let oldPushHandlerOnly = !self.respondsToSelector(Selector("application:didReceiveRemoteNotification:fetchCompletionHandler:"))
            let noPushPayload: AnyObject? = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
            if oldPushHandlerOnly || noPushPayload != nil {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.channels = ["global"]
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if application.applicationState == .Inactive  {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        
        PFPush.handlePush(userInfo)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        if application.applicationState == .Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        
        if PFUser.currentUser() != nil {
            completionHandler(UIBackgroundFetchResult.NewData)
            Router.sharedRouter().showHome(animated: true)
        } else {
            completionHandler(UIBackgroundFetchResult.NoData)
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        let currentInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
        }
    }
    
}