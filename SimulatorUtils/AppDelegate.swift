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
       statusBarItem.button?.title = "WIT Helper"
        
       let statusBarMenu = NSMenu(title: "WIT Status Bar Menu")
        
        statusBarMenu.addItem(
            withTitle: "Get SMS Code",
            action: #selector(AppDelegate.getSMS),
            keyEquivalent: "")

        statusBarMenu.addItem(
            withTitle: "Clear User Token",
            action: #selector(AppDelegate.clearToken),
            keyEquivalent: "")
       statusBarItem.menu = statusBarMenu
    }
    
    @objc func getSMS() {
        print("Get SMS Code")
        
        let response = showAlert(title:"SMS Code", information: "Type your UserID", hasInput: true)
        print(response)
        
        AF.request("http://user-dev-service.dev.svc.cluster.local:5000/user/api/v1/internal/user/get_sms_code/\(response)")
                    .responseJSON { response in
        //                https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#introduction
                        let jsonData = response.data
                        let json = try? JSONSerialization.jsonObject(with: jsonData!, options: []) as? [String: Any]
                        let smscode = json!["sms_verification_code"] as! NSNumber

                        self.showAlert(title:"Your SMS Code", information: "\(smscode)", hasInput: false)
                    }
    }

    @objc func clearToken() {
        print("Canceling your order :(")
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
    
}

