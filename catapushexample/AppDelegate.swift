//
//  AppDelegate.swift
//  catapushexample
//
//  Created by d2h on 27/10/16.
//  Copyright © 2016 D2H Srl. All rights reserved.
//

import UIKit
import BRYXBanner

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CatapushDelegate, VoIPNotificationDelegate, MessagesDispatchDelegate {
    

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        // Remote Push notifications
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        //application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        
        // Background fetch
        //application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        // CATAPUSH
        catapush_isConnecting=false;
        catapush_init();
        
        
        return true
    }
    
    var catapush_isConnecting = false;
    func catapush_init(){
        
        if(catapush_isConnecting==false){
            Catapush.setAppKey("xxx")
            Catapush.registerUserNotification(self, voIPDelegate: self)
            Catapush.start(withIdentifier: "test", andPassword: "xxx")
            Catapush.setupCatapushStateDelegate(self, andMessagesDispatcherDelegate: self)
            catapush_isConnecting = true;
        }
        
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Catapush.applicationDidEnterBackground(application)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Catapush.applicationWillEnterForeground(application)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Catapush.applicationDidBecomeActive(application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Catapush.applicationWillTerminate(application)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        print("didRegisterUserNotificationSettings");
        // Custom code (can be empty)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Custom code (can be empty)
        print("didRegisterForRemoteNotificationsWithDeviceToken");
        Catapush.registerForRemoteNotifications(withDeviceToken: deviceToken as Data!);
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Custom code (can be empty)
        let flowErrorAlertView = UIAlertView(title: "Error", message: error.localizedDescription, delegate: self, cancelButtonTitle: "Ok")
        flowErrorAlertView.show()
    }
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Custom code (can be empty)
        NSLog("didReceiveRemoteNotification");
        CatapushRemoteNotifications.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler);
    }
    
    func catapushDidConnectSuccessfully(_ catapush: Catapush!) {
        print("catapushDidConnectSuccessfully");
        let connectedAV = UIAlertView( title: "Connected",
                                       message: "Catapush Connected",
                                       delegate: self,
                                       cancelButtonTitle: "Ok")
        connectedAV.show()
    }
    
    func catapush(_ catapush: Catapush!, didFailOperation operationName: String!, withError error: Error!) {
        let errorMessage = "The operation " + operationName + " is failed with error " + error.localizedDescription
        print (errorMessage)
        let flowErrorAlertView = UIAlertView(title: "Error", message: errorMessage, delegate: self, cancelButtonTitle: "Ok")
        flowErrorAlertView.show()
    }
    
    func libraryDidFail(toSendMessage message: MessageIP!) {
        print("libraryDidFail");

    }
    
    public func libraryDidReceive(_ messageIP: MessageIP!) {
        print("libraryDidReceive");
        MessageIP.sendMessageReadNotification(messageIP)
        for message in Catapush.allMessages() {
            print("Message: \((message as AnyObject).body)")
        }
        show("libraryDidReceive");
    }
    func didReceiveIncomingPush(with payload: PKPushPayload!) {
        print("didReceiveIncomingPush");
        print(payload);
        
        let payloadDict = payload.dictionaryPayload["aps"] as? Dictionary<String, AnyObject>
        if(payloadDict != nil && payloadDict!["alert"] != nil ){
            if  let type = try payloadDict!["alert"]! as? String {
                show("didReceiveIncomingPush");
            }
        }
    }    
    func show(_ text: String){
        
        
        if UIApplication.shared.applicationState != UIApplicationState.active {
            
            let notification:UILocalNotification = UILocalNotification()
            notification.soundName = .none;
            //notification.soundName = "ringtone.mp3"
            if #available(iOS 8.2, *) {
                notification.alertTitle = "catapushexample"
            } else {
                // Fallback on earlier versions
            }
            notification.alertBody = text
            UIApplication.shared.presentLocalNotificationNow(notification)
        }else {
            let banner = Banner(title: "catapushexample", subtitle: text, image: nil, backgroundColor: UIColor(red:0/255.0, green:0/255.0, blue:0.0, alpha:1.000),didTapBlock:  nil );
            banner.dismissesOnTap = true
            banner.show(duration: 30.0)
        }
        
        
        

    }


}

