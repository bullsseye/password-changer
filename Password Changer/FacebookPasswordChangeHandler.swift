//
//  FacebookPasswordChangeHandler.swift
//  Password Changer
//
//  Created by Raman Gupta on 06/03/19.
//  Copyright © 2019 Raman Gupta. All rights reserved.
//

import UIKit
import WebKit

enum FacebookSteps:Int {
    case LoggedOut = 1
    case LoggedIn = 2
    case ChangeComplete = 4
}

class FacebookPasswordChangeHandler: NSObject, PasswordChangeHandler, WKNavigationDelegate {
    var wkWebView: WKWebView!
    var step = FacebookSteps.LoggedOut
    var delegate : PasswordChangeDelegate?
    var oldPassword = "Electronics2"
    var newPassword = "Electronics1"
    
    override init() {
        super.init()
        self.wkWebView = WKWebView.init(frame: .zero, configuration: WKWebViewConfiguration())
        self.wkWebView.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(self.wkWebView.url!.absoluteString)
        
        if (self.step == FacebookSteps.LoggedOut) {
            self.wkWebView.evaluateJavaScript("document.getElementById('signup-button').innerHTML") { (html: Any?, error: Error?) in
                if (error == nil) {
                    if (html != nil) {
                        let htmlString = html! as! String
                        if (htmlString == "Create New Account") {
                            print("We are not logged in")
                            self.wkWebView.evaluateJavaScript("document.getElementById('m_login_email').value='royalbird.raman@gmail.com'", completionHandler: { (html: Any?, error: Error?) in
                                if (error == nil) {
                                    self.wkWebView.evaluateJavaScript("document.getElementById('m_login_password').value='\(self.oldPassword)'", completionHandler: { (html: Any?, error: Error?) in
                                        if (error == nil) {
                                            self.wkWebView.evaluateJavaScript("document.getElementById('u_0_5').click();", completionHandler: { (html: Any?, error: Error?) in
                                                if (error == nil) {
                                                    print("Logged in successfully")
                                                    print(self.wkWebView.url!.absoluteString)
                                                    self.step = FacebookSteps.LoggedIn
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
                            })
                        }
                    }
                } else {
                    print(error.debugDescription)
                    print("maybe we are already logged in")
                    self.step = FacebookSteps.LoggedIn
                    let myURL = URL(string: "https://m.facebook.com/settings/security/password/")
                    let myRequest = URLRequest(url: myURL!)
                    self.wkWebView.load(myRequest)
                }
            }
        } else if (self.step == FacebookSteps.LoggedIn) {
            print("We are already logged in")
            self.wkWebView.evaluateJavaScript("document.getElementsByClassName('_56bg _55ws')[0].value='\(self.oldPassword)';") { (html: Any?, error: Error?) in
                if error == nil {
                    self.wkWebView.evaluateJavaScript("document.getElementsByClassName('_56bg _55ws')[1].value='\(self.newPassword)';", completionHandler: { (html: Any?, error: Error?) in
                        if error == nil {
                            self.wkWebView.evaluateJavaScript("document.getElementsByClassName('_56bg _55ws')[2].value='\(self.newPassword)';", completionHandler: { (html: Any?, error: Error?) in
                                if error == nil {
                                    self.wkWebView.evaluateJavaScript("document.getElementsByClassName('_54k8 _52jg _56bs _26vk _56b_ _56bw _56bu')[0].click();", completionHandler: { (html: Any?, error: Error?) in
                                        if (error == nil) {
                                            print("Password Changed")
                                            self.step = FacebookSteps.ChangeComplete
                                            print(self.wkWebView.url!.absoluteString)
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
                    })
                } else {
                    print(error.debugDescription)
                }
            }
        }
    }
    
    func loadURLToChangePassword(url: URL?) {
        let myURL = URL(string:"https://www.facebook.com/settings?tab=security&section=password&view")
        let myRequest = URLRequest(url: myURL!)
        self.wkWebView.load(myRequest)
    }
    
    func loadURL(url: URL?, withOTPOrPassword: String) {
        // not required
    }
}
