//
//  ViewController.swift
//  Password Changer
//
//  Created by Raman Gupta on 27/02/19.
//  Copyright © 2019 Raman Gupta. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UITableViewController {

    @IBOutlet var wTableView: UITableView!
    
    // Temp hardcoded data
    var data = [["Amazon": "www.amazon.in"]]
    
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
        return changePasswordCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

