//
//  PasswordChangeHandler.swift
//  Password Changer
//
//  Created by Raman Gupta on 28/02/19.
//  Copyright © 2019 Raman Gupta. All rights reserved.
//

import UIKit
import WebKit

enum Steps:Int {
    case PhoneScreen = 1
    case IntermediateScreen = 2
    case OTPOrPasswordScreen = 4
    case ChangePasswordScreen = 8
}

class PasswordChangeHandler: NSObject, WKNavigationDelegate {
    var wkWebView: WKWebView!
    var step = Steps.PhoneScreen
    
    override init() {
        super.init()
        let myURL = URL(string:"https://www.amazon.in/gp/css/account/forgot-password/email.html")
        let myRequest = URLRequest(url: myURL!)
        self.wkWebView.navigationDelegate = self
        self.wkWebView.load(myRequest)
    }
    
    // From count = 0 till Count = 1 should happen at server. The server should then send a redirect to the OTP screen.
    // The user's only responsibility will be to enter the OTP as there is no way to get this. This OTP screen will be
    // sent to our server. If there is any failure like wrong OTP entered or OTP expired will be checked at the server.
    // 1. In the case of OTP expired, the server will send appropriate response to  restart whole process on the client
    // after a certain interval or immediate action by the user.
    // 2. In case of wrong OTP, the server will throw the same screen of entering the OTP.
    // Once the Enter new password and Re-enter new password screen comes, this screen will be redirected to the client,
    // from where the client will enter the new password and re-enter new password. The server will also send the metadata
    // dictionary with key as "oldPassword" or "newPassword" and values as respective DOM IDs, so that client can enter the
    // old or new password in the respective ids. This dictionary will also contain the error strings etc for possible
    // failures, if happens that the client can directly detect on parsing the html. Once successful the password will be
    // changed securely.
    // With this method there will be enough information from the server if there is change in the password change screens
    // of the respective websites to dynamically handle those changes besides not sharing the password info with the server.
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if (self.step == Steps.PhoneScreen) {
            self.wkWebView.evaluateJavaScript("document.getElementById('ap_email').value='9899666063';") { (html: Any?, error: Error?) in
                if error == nil {
                    self.wkWebView.evaluateJavaScript("document.getElementById('continue').click();", completionHandler: { (html: Any?, error: Error?) in
                        if error == nil {
                            self.step = Steps.IntermediateScreen
                        } else {
                            print(error.debugDescription)
                        }
                    })
                } else {
                    print(error.debugDescription)
                }
            }
        } else if (self.step == Steps.IntermediateScreen) {
            self.wkWebView.evaluateJavaScript("document.getElementById('continue').click();") { (html: Any?, error: Error?) in
                if error == nil {
                    self.step = Steps.OTPOrPasswordScreen
                    print("Second Success")
                } else {
                    print(error.debugDescription)
                }
            }
        } else if (self.step == Steps.OTPOrPasswordScreen) {
            // do something here
        } else if (self.step == Steps.ChangePasswordScreen) {
            // do something here
        }
    }
}
