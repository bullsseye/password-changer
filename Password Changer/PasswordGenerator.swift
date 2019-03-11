//
//  PasswordGenerator.swift
//  Password Changer
//
//  Created by Raman Gupta on 11/03/19.
//  Copyright © 2019 Raman Gupta. All rights reserved.
//

import UIKit

class PasswordGenerator: NSObject {
    
    static let specialPasswordList = ["@", "$", "*"]
    
    static func generatePassword() -> String {
        var password = ""
        
        // First create the lower case characters
        for _ in 0..<7 {
            let randomInt = Int.random(in: 0..<26)
            password += String((UnicodeScalar(Int(UnicodeScalar("a").value) + randomInt)!))
        }
        
        // Add uppercase character
        let randomInt = Int.random(in: 0..<26)
        password += String((UnicodeScalar(Int(UnicodeScalar("A").value) + randomInt)!))
        
        // Add a number
        password += String(Int.random(in: 0..<10))
        
        // Add a special character
        password += PasswordGenerator.specialPasswordList[Int.random(in: 0..<3)]
        
        return password
    }
    
}
