//
//  TimelineViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//

import UIKit
import CoreLocation

class PlanViewController: UIViewController {
    var plan: Plan?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let plan = plan {
            print("Plan received: \(plan)")
            // TODO: update UI with activities, mood, duration
        }
    }
    
    
}
