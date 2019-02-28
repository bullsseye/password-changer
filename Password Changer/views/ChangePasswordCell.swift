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
    @IBOutlet weak var otpOrPasswordLabel: UILabel!
    @IBOutlet weak var enterOtpOrPasswordTextView: UITextView!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.otpOrPasswordLabel.isHidden = true
        self.otpOrPasswordLabel.isHidden = true
        self.enterOtpOrPasswordTextView.isHidden = true
        self.progressIndicator.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
