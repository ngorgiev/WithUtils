//
//  StatusItemController.swift
//  SimulatorUtils
//
//  Created by Nikola Gorgiev on 6/22/20.
//  Copyright © 2020 Nikola Gorgiev. All rights reserved.
//

import Cocoa
import Alamofire
import Foundation

class StatusItemController {
    let statusItem: NSStatusItem
    var onClick: ((NSStatusItem) -> Void)?
    
    var title: String {
        get {
            return statusItem.button?.title ?? ""
        }
        set {
            statusItem.button?.title = newValue
        }
    }
    
    

    
    func toggleRecord() -> Void {
       print(title)
        if(title == "Record")
        {
            title = "Stop Recording"
//            https://codewithchris.com/alamofire/
//            AF.request("https://httpbin.org/post", method: .post)
//            // PUT
//            AF.request("https://httpbin.org/put", method: .put)
//            // DELETE
//            AF.request("https://httpbin.org/delete", method: .delete)
            //http://user-dev-service.dev.svc.cluster.local:5000/user/api/v1/internal/user/get_sms_code/1448
            AF.request("http://user-dev-service.dev.svc.cluster.local:5000/user/api/v1/internal/user/get_sms_code/1448")
            .responseJSON { response in
//                https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#introduction
                let jsonData = response.data
                let json = try? JSONSerialization.jsonObject(with: jsonData!, options: []) as? [String: Any]
                let smscode = json!["sms_verification_code"] as! NSNumber

                let alert = NSAlert()
                alert.messageText = "SMS Code"
                alert.informativeText =  "\(smscode)"
                
                
                let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
                txt.stringValue = "defaultValue"
                alert.accessoryView = txt
                
                alert.addButton(withTitle: "OK")
                alert.addButton(withTitle: "Cancel")
                alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
            }

        }
        else
        {
            title = "Record"
        }
    }
   
    
    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        self.statusItem.button?.target = self
        self.statusItem.button?.action = #selector(performClick(_:))
    }
    
    convenience init(title: String) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.init(statusItem: item)
        statusItem.button?.title = title
    }
    
    @objc private func performClick(_ sender: Any) {
        onClick?(statusItem)
        toggleRecord()
    }
}
