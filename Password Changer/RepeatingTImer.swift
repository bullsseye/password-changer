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
    
    var delegate: PasswordChangeDelegate?
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let queue = DispatchQueue.global(qos: .background)
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now(), repeating: self.timeInterval)
        t.setEventHandler(handler: self.eventHandler)
        return t
    }()
    
    lazy var eventHandler: (() -> Void)? = { [weak self] in
        let url = URL(string: "http://127.0.0.1:8000/notification/")!
        var request = URLRequest(url: url)
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.httpMethod = HTTPMethod.get.rawValue
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        
        Alamofire.request(request).responseJSON { (response) in
            if (response.result.isSuccess) {
                let urlString: String = response.result.value! as! String
                if (urlString != "None" && self != nil && self!.delegate != nil) {
                    self!.delegate!.didReceiveRemoteNotificationToChangePassword(fromRepeatingTimer: self!, urlString: urlString)
                    self!.timer.suspend()
                }
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
