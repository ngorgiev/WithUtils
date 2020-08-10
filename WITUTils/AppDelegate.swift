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
    
    let environment = NSMenuItem()
    
    let font = NSFont.monospacedDigitSystemFont(ofSize: 9.0, weight: NSFont.Weight.regular)
    var env = ""
    
    var API_DEV_BASE_URL = "http://user-dev-service.dev.svc.cluster.local:5000"
    var API_TEST_BASE_URL = "http://user-test-service.test.svc.cluster.local:5000"
    var API_URL = ""
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        //       let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(
            withLength: NSStatusItem.variableLength)
        statusBarItem.button?.font = font
        statusBarItem.button?.title = "WithMe"
        
        
        env = defaults.string(forKey: "wit_env") ?? "dev"
        
        setEnvironment(_env: env)
        
        let statusBarMenu = NSMenu(title: "WIT Status Bar Menu")
        
        //        let environment = NSMenuItem()
        environment.submenu = NSMenu()
        environment.title = "Environment (\(env))"
        environment.submenu?.items = [NSMenuItem(title: "Dev", action: #selector(AppDelegate.setDev), keyEquivalent: "d"),NSMenuItem(title: "Test", action: #selector(AppDelegate.setTest), keyEquivalent: "t")]
        
        statusBarMenu.addItem(environment)
        
        
        statusBarMenu.addItem(
            withTitle: "Get SMS Code",
            action: #selector(AppDelegate.getSMS),
            keyEquivalent: "1")
        
        statusBarMenu.addItem(
            withTitle: "Get User PIN",
            action: #selector(AppDelegate.getUserPIN),
            keyEquivalent: "2")
        
        statusBarMenu.addItem(
            withTitle: "Clear User Token",
            action: #selector(AppDelegate.clearToken),
            keyEquivalent: "3")
        
        statusBarMenu.addItem(
            withTitle: "Unlock Account",
            action: #selector(AppDelegate.unlockAccount),
            keyEquivalent: "4")
        
        statusBarMenu.addItem(
            withTitle: "Soft Delete User",
            action: #selector(AppDelegate.softDeleteUser),
            keyEquivalent: "5")
        
        statusBarMenu.addItem(
            withTitle: "Show BarCode",
            action: #selector(AppDelegate.togglePopover(_:)),
            keyEquivalent: "q")
        
        statusBarMenu.addItem(NSMenuItem.separator())
        
        statusBarMenu.addItem(
            withTitle: "Quit",
            action: #selector(AppDelegate.quit),
            keyEquivalent: "q")
        
        statusBarItem.menu = statusBarMenu
        
        scheduledTimerWithTimeInterval()
        
        let image = BarcodeGenerator.generate(from: "barcode-string",
                                              descriptor: .code128,
                                              size: CGSize(width: 800, height: 300))
        
    }
    
    @objc func setEnvironment(_env: String){
        environment.title = "Environment (\(_env))"
        defaults.set(_env, forKey: "wit_env")

        if(_env == "dev")
        {
            API_URL = API_DEV_BASE_URL
        }
        else
        {
            API_URL = API_TEST_BASE_URL
        }
    }
    
    @objc func setDev(){
        //          environment.title = "Environment (dev)"
        setEnvironment(_env: "dev")
    }
    
    @objc func setTest(){
        //          environment.title = "Environment (test)"
        setEnvironment(_env: "test")
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: Selector("pinger"), userInfo: nil, repeats: true)
    }
    
    @objc func pinger(){
        PlainPing.ping("www.apple.com", withTimeout: 1.0, completionBlock: { (timeElapsed:Double?, error:Error?) in
            if let latency = timeElapsed {
                
                var roundedString = String(format: "%.2f", latency)
                //                print("latency (ms): \(roundedString)")
                self.statusBarItem.button?.title = "WithMe\n(\(roundedString)ms)"
                self.statusBarItem.button?.contentTintColor = NSColor(calibratedRed: 0, green: 1, blue: 0, alpha: 1)
            }
            
            if let error = error {
                //                print("error: \(error.localizedDescription)")
                self.statusBarItem.button?.title = "WithMe\n(OffLine)"
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
            AF.request("\(API_URL)/user/api/v1/internal/user/get_sms_code/\(response)")
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
            AF.request("\(API_URL)/user/api/v1/debug/user/delete_jwts_and_login_uuid/\(response)", method: .post)
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
            AF.request("\(API_URL)/user/api/v1/debug/user/get_pin/\(response)")
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
            AF.request("\(API_URL)/user/api/v1/auth/system_user/unlock_patient_account/\(phone)", method: .post)
                .responseJSON { response in
                    self.showInfoAlert(title: "Information", information: "Account Unlocked")
            }
        }
        //http://user-dev-service.dev.svc.cluster.local:5000/user/api/v1/user/user_apis_apis_user_unlock_patient_account/
    }
    
    @objc func softDeleteUser() {
        print("Soft Delete User")
        let response = showAlert(title:"Soft Delete User", information: "Type your UserID", hasInput: true)
        if(response as AnyObject !== "" as AnyObject)
        {
            print(response)
            AF.request("\(API_URL)/user/api/v1/debug/user/soft_delete_user/\(response)",method: .post)
                .responseJSON { response in
                    
                    self.showInfoAlert(title: "Information", information: "User Deleted")
            }
        }
    }
    
    @objc func togglePopover(_ sender: NSStatusItem) {
    }
    
    @objc func quit() {
        print("Quit App")
        
        NSApplication.shared.terminate(self)
        
    }
    
    func openUrl() {
        let url = URL(string: "https://www.google.com")!
        if NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
            
        }
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

class BarcodeGenerator {
    enum Descriptor: String {
        case code128 = "CICode128BarcodeGenerator"
        case pdf417 = "CIPDF417BarcodeGenerator"
        case aztec = "CIAztecCodeGenerator"
        case qr = "CIQRCodeGenerator"
    }
    
    class func generate(from string: String,
                        descriptor: Descriptor,
                        size: CGSize) -> CIImage? {
        let filterName = descriptor.rawValue
        
        guard let data = string.data(using: .ascii),
            let filter = CIFilter(name: filterName) else {
                return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        
        guard let image = filter.outputImage else {
            return nil
        }
        
        let imageSize = image.extent.size
        
        let transform = CGAffineTransform(scaleX: size.width / imageSize.width,
                                          y: size.height / imageSize.height)
        let scaledImage = image.transformed(by: transform)
        
        return scaledImage
    }
}



struct AppDelegate_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
