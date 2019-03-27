//
//  RepeatingTImer.swift
//  Password Changer
//
//  Created by Raman Gupta on 27/03/19.
//  Copyright © 2019 Raman Gupta. All rights reserved.
//

import UIKit
import Alamofire


/// RepeatingTimer mimics the API of DispatchSourceTimer but in a way that prevents
/// crashes that occur from calling resume multiple times on a timer that is
class RepeatingTimer {
    
    let timeInterval: TimeInterval
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now(), repeating: self.timeInterval)
        t.setEventHandler(handler: self.eventHandler)
        return t
    }()
    
    var eventHandler: (() -> Void)? = {
        let url = URL(string: "http://127.0.0.1:8000/notification/")!
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        Alamofire.request(request).responseJSON { (response) in
            if (response.result.isSuccess) {
                print(response.result.value!)
            } else {
                print("Request not successful, response: \(response)")
            }
        }
    }
    
    private enum State {
        case suspended
        case resumed
    }
    
    private var state: State = .suspended
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }
    
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}
