//
//  GooglePasswordChangeHandler.swift
//  Password Changer
//
//  Created by Raman Gupta on 07/03/19.
//  Copyright © 2019 Raman Gupta. All rights reserved.
//

import UIKit
import WebKit

enum GoogleSigninSteps:Int {
    case GoogleSigninStepsAskForContinueScreen = 1
    case GoogleSigninStepsEnterEmailScreen = 2
    case GoogleSigninStepsEnterPasswordScreen = 4
    case GoogleSigninStepsEnterNewPasswordScreen = 8
    case GoogleSigninStepsPasswordChangeComplete = 16
}

class GooglePasswordChangeHandler: NSObject, PasswordChangeHandler, WKNavigationDelegate {
    var wkWebView: WKWebView!
    var step = GoogleSigninSteps.GoogleSigninStepsAskForContinueScreen
    var delegate : PasswordChangeDelegate?
    var oldPassword = "***************"
    var newPassword = "***************"
    
    override init() {
        super.init()
        self.wkWebView = WKWebView.init(frame: .zero, configuration: WKWebViewConfiguration())
        self.wkWebView.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(self.wkWebView.url!.absoluteString)
        if (self.step == GoogleSigninSteps.GoogleSigninStepsAskForContinueScreen) {
            self.wkWebView.evaluateJavaScript("document.getElementsByClassName('FKF6mc TpQm9d')[0].click();") { (html: Any?, error: Error?) in
                if (error == nil) {
                    self.step = GoogleSigninSteps.GoogleSigninStepsEnterEmailScreen
                } else {
                    print(error.debugDescription)
                    print("Maybe we are at the enter email screen")
                    self.loadURLToChangePassword(url: nil)
                    self.step = GoogleSigninSteps.GoogleSigninStepsEnterEmailScreen
                }
            }
        } else if (self.step == GoogleSigninSteps.GoogleSigninStepsEnterEmailScreen) {
            self.wkWebView.evaluateJavaScript("document.getElementById('Email').value='royalbird.raman@gmail.com'") { (html: Any?, error: Error?) in
                if (error == nil) {
                    self.wkWebView.evaluateJavaScript("document.getElementById('next').click();", completionHandler: { (html:Any?, error: Error?) in
                        if (error == nil) {
                            self.step = GoogleSigninSteps.GoogleSigninStepsEnterPasswordScreen
                        } else {
                            print(error.debugDescription)
                            print("Maybe we are at the enter password screen")
                            self.loadURLToChangePassword(url: nil)
                            self.step = GoogleSigninSteps.GoogleSigninStepsEnterPasswordScreen
                        }
                    })
                } else {
                    print(error.debugDescription)
                    print("Maybe we are at the enter password screen")
                    self.loadURLToChangePassword(url: nil)
                    self.step = GoogleSigninSteps.GoogleSigninStepsEnterPasswordScreen
                }
            }
        } else if (self.step == GoogleSigninSteps.GoogleSigninStepsEnterPasswordScreen) {
            self.wkWebView.evaluateJavaScript("document.getElementById('Passwd').value='\(self.oldPassword)'") { (html: Any?, error: Error?) in
                if (error == nil) {
                    print(html!)
                    self.wkWebView.evaluateJavaScript("document.getElementById('signIn').click();", completionHandler: { (html: Any?, error: Error?) in
                        if (error == nil) {
                            self.step = GoogleSigninSteps.GoogleSigninStepsEnterNewPasswordScreen
                        } else {
                            print(error.debugDescription)
                        }
                    })
                } else {
                    print(error.debugDescription)
                }
            }
        } else if (self.step == GoogleSigninSteps.GoogleSigninStepsEnterNewPasswordScreen) {
            self.wkWebView.evaluateJavaScript("document.getElementsByClassName('whsOnd zHQkBf')[0].value='\(self.newPassword)'") { (html: Any?, error: Error?) in
                if (error == nil) {
                    self.wkWebView.evaluateJavaScript("document.getElementsByClassName('whsOnd zHQkBf')[1].value='\(self.newPassword)'", completionHandler: { (html: Any?, error: Error?) in
                        if (error == nil) {
                            self.wkWebView.evaluateJavaScript("document.getElementsByClassName('U26fgb O0WRkf zZhnYe e3Duub C0oVfc')[0].click()", completionHandler: { (html: Any?, error: Error?) in
                                if (error == nil) {
                                    self.step = GoogleSigninSteps.GoogleSigninStepsPasswordChangeComplete
                                    self.delegate!.passwordChangeComplete(forPasswordHandlerObj: self)
                                } else {
                                    print(error.debugDescription)
                                }
                            })
                        } else {
                            print(error.debugDescription)
                        }
                    })
                } else {
                    print(error.debugDescription)
                }
            }
        }
    }
    
    func loadURLToChangePassword(url: URL?) {
        let myURL = URL(string:"https://accounts.google.com/ServiceLogin/identifier?service=accountsettings&passive=1209600&osid=1&continue=https%3A%2F%2Fmyaccount.google.com%2Fsecurity%2Fsignin%3Fcontinue%3Dhttps%3A%2F%2Fmyaccount.google.com%2Fsigninoptions%2Fpassword&followup=https%3A%2F%2Fmyaccount.google.com%2Fsecurity%2Fsignin%3Fcontinue%3Dhttps%3A%2F%2Fmyaccount.google.com%2Fsigninoptions%2Fpassword&rart=ANgoxce_Od3PxaYxlC7_tIF_yqcPvju9edvY8aYpeLwFhUEDIPyFIu3wVEItg0BsakFAyX8VZ-THyG1I7P6zcq-dhEiVHUcrAg&authuser=0&csig=AF-SEnYuVyJjaiBLjOza%3A1552025334&flowName=GlifWebSignIn&flowEntry=AddSession")
        let myRequest = URLRequest(url: myURL!)
        self.wkWebView.load(myRequest)
    }
    
    func loadURL(url: URL?, withOTPOrPassword: String) {
        // not required
    }
}

