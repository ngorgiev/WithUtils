//
//  AppDelegate.swift
//  SimulatorUtils
//
//  Created by Nikola Gorgiev on 6/22/20.
//  Copyright © 2020 Nikola Gorgiev. All rights reserved.
//

import Cocoa
import SwiftUI
import Alamofire
import Foundation
import PlainPing

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    let defaults = UserDefaults.standard
    var timer = Timer()
    let statusBar = NSStatusBar.system
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
//       let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(
       withLength: NSStatusItem.squareLength)
       statusBarItem.button?.title = "WIT"
        
        
       let statusBarMenu = NSMenu(title: "WIT Status Bar Menu")
        
        statusBarMenu.addItem(
            withTitle: "Get SMS Code",
            action: #selector(AppDelegate.getSMS),
            keyEquivalent: "1")

        statusBarMenu.addItem(
            withTitle: "Clear User Token",
            action: #selector(AppDelegate.clearToken),
            keyEquivalent: "2")
        
        statusBarMenu.addItem(
            withTitle: "Get User PIN",
            action: #selector(AppDelegate.getUserPIN),
            keyEquivalent: "3")
        
        statusBarMenu.addItem(
        withTitle: "Unlock Account",
        action: #selector(AppDelegate.unlockAccount),
        keyEquivalent: "4")
        
        statusBarMenu.addItem(NSMenuItem.separator())
        
        statusBarMenu.addItem(
        withTitle: "Quit",
        action: #selector(AppDelegate.quit),
        keyEquivalent: "q")
        
       statusBarItem.menu = statusBarMenu
        
       scheduledTimerWithTimeInterval()
     
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: Selector("pinger"), userInfo: nil, repeats: true)
    }
    
    @objc func pinger(){
        PlainPing.ping("www.google.com", withTimeout: 1.0, completionBlock: { (timeElapsed:Double?, error:Error?) in
            if let latency = timeElapsed {
                print("latency (ms): \(latency)")
                self.statusBarItem.button?.contentTintColor = NSColor(calibratedRed: 0, green: 1, blue: 0, alpha: 1)
            }
            
            if let error = error {
                print("error: \(error.localizedDescription)")
                self.statusBarItem.button?.contentTintColor = NSColor(calibratedRed: 1, green: 0, blue: 0, alpha: 1)
            }
        })
    }
    
    @objc func getSMS() {
        print("Get SMS Code")
        
        let response = showAlert(title:"SMS Code", information: "Type your UserID", hasInput: true)
        
        if(response as AnyObject !== "" as AnyObject)
        {
        //https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#introduction
        AF.request("http://user-dev-service.dev.svc.cluster.local:5000/user/api/v1/internal/user/get_sms_code/\(response)")
                    .responseJSON { response in
                        let jsonData = response.data
                        let json = try? JSONSerialization.jsonObject(with: jsonData!, options: []) as? [String: Any]
                        let smscode = json!["sms_verification_code"] as! NSNumber
                        
                        self.copyToClipboard(value: "\(smscode)")
                        self.showInfoAlert(title: "Sms Code Copied to Clipboard", information: "code: \(smscode)")
                    }
        }
    }

    @objc func clearToken() {
        print("clear Token")
    
        let response = showAlert(title:"Delete User Token", information: "Type your UserID", hasInput: true)
        
        if(response as AnyObject !== "" as AnyObject)
        {
            AF.request("http://user-dev-service.dev.svc.cluster.local:5000/user/api/v1/debug/user/delete_jwts_and_login_uuid/\(response)", method: .post)
            .responseJSON { response in
                debugPrint(response)
            }.responseData { response in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    self.showInfoAlert(title: "Clear Token", information: "User Token Deleted")
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
    
    @objc func getUserPIN() {
        print("Get User Pin")
        let response = showAlert(title:"Get User PIN", information: "Type your UserID", hasInput: true)
        if(response as AnyObject !== "" as AnyObject)
        {
            AF.request("http://user-dev-service.dev.svc.cluster.local:5000/user/api/v1/debug/user/get_pin/\(response)")
            .responseJSON { response in
                
                let jsonData = response.data
                let json = try? JSONSerialization.jsonObject(with: jsonData!, options: []) as? [String: Any]
                let pin = json!["user_pin"] as! NSString
                
                self.copyToClipboard(value: "\(pin)")
                self.showInfoAlert(title: "PIN Copied to Clipboard", information: "PIN: \(pin)")
            }
        }
    }
    
    @objc func unlockAccount() {
        print("Unlock Account")
        let response = showAlert(title:"Unlock Account", information: "Type your phone number", hasInput: true)
        if(response as AnyObject !== "" as AnyObject)
        {
            let encoded = response.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            let phone = "\(encoded!)"
            print("escapedString: \(phone)")
            AF.request("http://user-dev-service.dev.svc.cluster.local:5000/user/api/v1/auth/system_user/unlock_patient_account/\(phone)", method: .post)
            .responseJSON { response in
                self.showInfoAlert(title: "Information", information: "Account Unlocked")
            }
        }
        //http://user-dev-service.dev.svc.cluster.local:5000/user/api/v1/user/user_apis_apis_user_unlock_patient_account/

        
    }
    
    @objc func quit() {
        print("Quit App")
        NSApplication.shared.terminate(self)
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    //let Insert code here to tear down your application
    }
    
    
    func showAlert(title: String, information: String, hasInput: Bool) -> String
    {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText =  information

        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = defaults.string(forKey: "userId") ?? ""
        if(hasInput)
        {
        alert.accessoryView = txt
        }

        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        let response: NSApplication.ModalResponse = alert.runModal()
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            defaults.set(txt.stringValue, forKey: "userId")
            return txt.stringValue
        }
        return ""
    }
    
    func showInfoAlert(title: String, information: String) -> Void
    {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText =  information
        
        alert.runModal()
    }
    
    func copyToClipboard(value: String) -> Void {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
    }
    
}



struct AppDelegate_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
