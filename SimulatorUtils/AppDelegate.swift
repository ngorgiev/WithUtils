//
//  AppDelegate.swift
//  SimulatorUtils
//
//  Created by Nikola Gorgiev on 6/22/20.
//  Copyright © 2020 Nikola Gorgiev. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItemController = StatusItemController(title: "WIT Helper")
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
       
        statusItemController.onClick = { statusItem in
            print("click")
            let alert = NSAlert()
            alert.messageText = "SMS Code"
            alert.informativeText =  "UserId"
            
            
            let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            txt.stringValue = ""
            alert.accessoryView = txt
            
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
//            alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
            let response: NSApplication.ModalResponse = alert.runModal()
            if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
                print(txt.stringValue)
            } else {
                print("empty")
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    //let Insert code here to tear down your application
    }
    
}

