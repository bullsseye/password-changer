//
//  ViewController.swift
//  Password Changer
//
//  Created by Raman Gupta on 27/02/19.
//  Copyright © 2019 Raman Gupta. All rights reserved.
//

import UIKit
import WebKit

protocol PasswordChangeDelegate {
    func didRequestForPasswordChange(forCell: ChangePasswordCell, forURL: URL?)
    func didRequestForOTPOrPassword(forPasswordHandlerObj: PasswordChangeHandler)
    func didEnterOTPOrPassword(forCell: ChangePasswordCell, otpOrPassword: String)
    func didCompleteVerificationOfOTP(forPasswordHandlerObj: PasswordChangeHandler)
    func passwordChangeComplete(forPasswordHandlerObj: PasswordChangeHandler)
}

extension NSNotification.Name {
    public static let PasswordChangeHandlerDidRequestOTPOrPassword = Notification.Name("PasswordChangeHandlerDidRequestOTPOrPassword")
    public static let PasswordChangeHandlerDidCompleteVerificationOfOTP = Notification.Name("PasswordChangeHandlerDidCompleteVerificationOfOTP")
    public static let PasswordChangeHandlerDidCompletePasswordChange = Notification.Name("PasswordChangeHandlerDidCompletePasswordChange")
    public static let ChangePasswordCellDidAskForPasswords = Notification.Name("ChangePasswordCellDidAskForPasswords")
    public static let ChangePasswordCellDidGetDeSelected = Notification.Name("ChangePasswordCellDidGetDeSelected")
}

class ViewController: UITableViewController, PasswordChangeDelegate {
    @IBOutlet var wTableView: UITableView!
    
    // Temp hardcoded data
    var data = [["Amazon": "www.amazon.in"], ["Facebook": "m.facebook.com"], ["Google": "myaccount.google.com"]]
    var urlVsObjectHandlerClassString = ["www.amazon.in": AmazonPasswordChangeHandlerConst,
                                         "m.facebook.com": FacebookPasswordChangeHandlerConst,
                                         "myaccount.google.com": GooglePasswordChangeHandlerConst]
    
    static let AmazonPasswordChangeHandlerConst = "AmazonPasswordChangeHandler"
    static let FacebookPasswordChangeHandlerConst = "FacebookPasswordChangeHandler"
    static let GooglePasswordChangeHandlerConst = "GooglePasswordChangeHandler"
    
    var urlVsPasswordChangeHandler = [String: PasswordChangeHandler]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.wTableView.register(UINib(nibName: "ChangePasswordCell", bundle: nil), forCellReuseIdentifier: "ChangePasswordCell")
    }
    
    // MARK - TableViewDelegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let changePasswordCell = self.wTableView.dequeueReusableCell(withIdentifier: "ChangePasswordCell", for: indexPath) as! ChangePasswordCell
        let label = Array(self.data[indexPath.row].keys)[0]
        changePasswordCell.websiteLabel.text = label
        let urlString = self.data[indexPath.row][label]
        changePasswordCell.url = urlString != nil ? URL(string: urlString!) : nil
        changePasswordCell.delegate = self
        return changePasswordCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // FIXME:(ramang) Use reflection rather than the factory method to create class objects
    
    func ClassFromClassName(Class : String) -> PasswordChangeHandler? {
        if (Class == ViewController.AmazonPasswordChangeHandlerConst) {
            return AmazonPasswordChangeHandler()
        } else if (Class == ViewController.FacebookPasswordChangeHandlerConst) {
            return FacebookPasswordChangeHandler()
        } else if (Class == ViewController.GooglePasswordChangeHandlerConst) {
            return GooglePasswordChangeHandler()
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let label = Array(self.data[indexPath.row].keys)[0]
        let urlString = self.data[indexPath.row][label]
        self.changePasswordCellDidAskForPasswords(url: URL(string: urlString!))
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let label = Array(self.data[indexPath.row].keys)[0]
        let urlString = self.data[indexPath.row][label]
        if (urlString != nil) {
            let url = URL(string: urlString!)
            if (url != nil) {
                NotificationCenter.default.post(name: Notification.Name.ChangePasswordCellDidGetDeSelected,
                                                object: self,
                                                userInfo: ["url": url!])
            } else {
                assertionFailure("Invalid url found")
            }
        }
    }
    
    // MARK - PasswordChangeDelegate methods
    
    func didRequestForPasswordChange(forCell: ChangePasswordCell, forURL: URL?) {
        if (forURL != nil) {
            forCell.shouldShowProgressIndicator(startProgressIndicator: true, forURL: forURL)
            var passwordChangeHandlerObj = self.urlVsPasswordChangeHandler[forURL!.absoluteString]
            if (passwordChangeHandlerObj == nil) {
                let classString = self.urlVsObjectHandlerClassString[forURL!.absoluteString]
                if (classString != nil) {
                    passwordChangeHandlerObj = self.ClassFromClassName(Class: classString!)
                    passwordChangeHandlerObj?.delegate = self
                    self.urlVsPasswordChangeHandler[forURL!.absoluteString] = passwordChangeHandlerObj
                } else {
                    assertionFailure("Invalid URL or URL not supported")
                }
            }
            passwordChangeHandlerObj!.loadURLToChangePassword(url: forURL)
        }
    }
    
    func didRequestForOTPOrPassword(forPasswordHandlerObj: PasswordChangeHandler) {
        let url = forPasswordHandlerObj.wkWebView.url
        if (url != nil) {
            NotificationCenter.default.post(name: Notification.Name.PasswordChangeHandlerDidRequestOTPOrPassword,
                                            object: self,
                                            userInfo: ["url": forPasswordHandlerObj.wkWebView.url!])
        }
    }
    
    func didEnterOTPOrPassword(forCell: ChangePasswordCell, otpOrPassword: String) {
        let passwordChangeHandlerObj = self.urlVsPasswordChangeHandler[forCell.url!.absoluteString]
        passwordChangeHandlerObj!.loadURL(url: passwordChangeHandlerObj!.wkWebView.url, withOTPOrPassword: otpOrPassword)
    }
    
    func didCompleteVerificationOfOTP(forPasswordHandlerObj: PasswordChangeHandler) {
        let url = forPasswordHandlerObj.wkWebView.url
        if (url != nil) {
            NotificationCenter.default.post(name: Notification.Name.PasswordChangeHandlerDidCompleteVerificationOfOTP,
                                            object: self,
                                            userInfo: ["url": forPasswordHandlerObj.wkWebView.url!])
        }
    }
    
    func passwordChangeComplete(forPasswordHandlerObj: PasswordChangeHandler) {
        let url = forPasswordHandlerObj.wkWebView.url
        if (url != nil) {
            NotificationCenter.default.post(name: Notification.Name.PasswordChangeHandlerDidCompletePasswordChange,
                                            object: self,
                                            userInfo: ["url": forPasswordHandlerObj.wkWebView.url!])
        }
    }
    
    func changePasswordCellDidAskForPasswords(url: URL?) {
        if (url != nil) {
            var passwordChangeHandlerObj = self.urlVsPasswordChangeHandler[url!.absoluteString]
            if (passwordChangeHandlerObj == nil) {
                let classString = self.urlVsObjectHandlerClassString[url!.absoluteString]
                if (classString != nil) {
                    passwordChangeHandlerObj = self.ClassFromClassName(Class: classString!)
                    passwordChangeHandlerObj?.delegate = self
                    self.urlVsPasswordChangeHandler[url!.absoluteString] = passwordChangeHandlerObj
                } else {
                    assertionFailure("Invalid URL or URL not supported")
                }
            }
            NotificationCenter.default.post(name: Notification.Name.ChangePasswordCellDidAskForPasswords,
                                            object: self,
                                            userInfo: ["url": url!,
                                                       "oldPassword": passwordChangeHandlerObj!.oldPassword,
                                                       "newPassword": passwordChangeHandlerObj!.presentPassword])
        } else {
            assertionFailure("url found nil for a cell")
        }
    }
}

