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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
//    let statusItemController = StatusItemController(title: "WIT Helper")
    
    
     var statusBarItem: NSStatusItem!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
       let statusBar = NSStatusBar.system
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
            withTitle: "Create Assesment",
            action: #selector(AppDelegate.createAssesment),
            keyEquivalent: "3")
        statusBarMenu.addItem(NSMenuItem.separator())
        
        
        statusBarMenu.addItem(
        withTitle: "Quit",
        action: #selector(AppDelegate.quit),
        keyEquivalent: "q")
        
       statusBarItem.menu = statusBarMenu
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
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("clear Token", forType: .string)
        // Read copied string
//        NSPasteboard.general.string(forType: .string)

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
    
    @objc func createAssesment() {
        print("Create Assessment")
        
        AF.request("http://messaging-bot-rest-dev-service.dev.svc.cluster.local:5000/messaging-bot/api/v1#/Message/add_message_messaging_bot_api_v1_message_add_message_post", method: .post)
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
        txt.stringValue = ""
        if(hasInput)
        {
        alert.accessoryView = txt
        }
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        let response: NSApplication.ModalResponse = alert.runModal()
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
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
