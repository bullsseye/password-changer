//
//  ChangePasswordCell.swift
//  Password Changer
//
//  Created by Raman Gupta on 28/02/19.
//  Copyright © 2019 Raman Gupta. All rights reserved.
//

import UIKit

class ChangePasswordCell: UITableViewCell {

    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var enterOtpOrPasswordTextView: UITextView!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var okButton: UIButton!
    
    var url: URL?
    
    var delegate: PasswordChangeDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.enterOtpOrPasswordTextView.isHidden = true
        self.progressIndicator.isHidden = true
        self.okButton.isHidden = true
        self.changePasswordButton.isEnabled=true
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRequestForOTPorPassword), name: Notification.Name.PasswordChangeHandlerDidRequestOTPOrPassword, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didCompleteOTPVerification), name: Notification.Name.PasswordChangeHandlerDidCompleteVerificationOfOTP, object:nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didCompleteChangingPassword), name: Notification.Name.PasswordChangeHandlerDidCompletePasswordChange, object: nil)
    }
    
    @IBAction func changePasswordAction(_ sender: Any) {
        if (self.delegate != nil) {
            self.delegate!.didRequestForPasswordChange(forCell: self, forURL: self.url ?? nil)
        }
    }
    
    func shouldShowProgressIndicator(startProgressIndicator: Bool, forURL: URL?) {
        print("shouldShowProgressIndicator: startProgressIndicator: \(startProgressIndicator), forURL: \(String(describing: forURL))")
        if (self.url != nil && self.url!.absoluteString == forURL!.absoluteString) {
            if (startProgressIndicator) {
                self.okButton.isHidden = true
                self.enterOtpOrPasswordTextView.isHidden = true
                self.changePasswordButton.isHidden = true
                self.progressIndicator.startAnimating()
                self.progressIndicator.isHidden = false
            } else {
                self.progressIndicator.stopAnimating()
                self.progressIndicator.isHidden = true
                self.enterOtpOrPasswordTextView.isHidden = false
                self.okButton.isHidden = false
            }
        }
    }
    
    @objc func didRequestForOTPorPassword(_ notification: Notification) {
        let url: URL? = notification.userInfo?["url"] as! URL?
        print("here")
        if (url != nil) {
            if (self.url != nil) {
                if (self.url!.absoluteString == url!.absoluteString.split(separator: "/")[1]) {
                    self.shouldShowProgressIndicator(startProgressIndicator: false, forURL: URL(string: String(url!.absoluteString.split(separator: "/")[1])))
                }
            }
        }
    }
    
    @objc func didCompleteOTPVerification(_ notification: Notification) {
        let url: URL? = notification.userInfo?["url"] as! URL?
        if (url != nil) {
            if (self.url != nil) {
                if (self.url!.absoluteString == url!.absoluteString.split(separator: "/")[1]) {
                    self.shouldShowProgressIndicator(startProgressIndicator: true, forURL: URL(string: String(url!.absoluteString.split(separator: "/")[1])))
                }
            }
        }
    }
    
    @objc func didCompleteChangingPassword(_ notification: Notification) {
        let url: URL? = notification.userInfo?["url"] as! URL?
        if (url != nil) {
            if (self.url != nil) {
                if (self.url!.absoluteString == url!.absoluteString.split(separator: "/")[1]) {
                    self.completePasswordChangeSucessfully()
                }
            }
        }
    }
    
    func completePasswordChangeSucessfully() {
        self.progressIndicator.stopAnimating()
        self.progressIndicator.isHidden = true
        self.enterOtpOrPasswordTextView.isHidden = true
        self.okButton.isHidden = true
        self.changePasswordButton.setTitle("Password Changed Successfully", for: UIControl.State.highlighted)
        self.changePasswordButton.isEnabled = false
    }
    

    @IBAction func didEnterOTPOrPassword(_ sender: Any) {
        let otpOrPassword = self.enterOtpOrPasswordTextView.text
        if (otpOrPassword != "") {
            if (self.delegate != nil) {
                self.delegate!.didEnterOTPOrPassword(forCell: self, otpOrPassword: otpOrPassword!)
            }
        } else {
            print("Empty OTP entered")
        }
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
