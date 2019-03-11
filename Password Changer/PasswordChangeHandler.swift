//
//  PasswordChangeHandler.swift
//  Password Changer
//
//  Created by Raman Gupta on 28/02/19.
//  Copyright © 2019 Raman Gupta. All rights reserved.
//

import UIKit
import WebKit

protocol PasswordChangeHandler {
    
    var delegate : PasswordChangeDelegate? {get set}
    
    var wkWebView: WKWebView! {get}
    
    var oldPassword: String {get}
    
    var presentPassword: String {get}
    
    func loadURLToChangePassword(url: URL?)
    
    func loadURL(url: URL?, withOTPOrPassword: String)
}
