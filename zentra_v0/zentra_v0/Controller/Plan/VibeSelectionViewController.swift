//
//  VibeSelectionViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//

import UIKit
import CoreLocation


class VibeSelectionViewController: UIViewController  {
    
    @IBOutlet var InterestCollection: [UIStackView]!
    
    
    @IBOutlet weak var interestStackView: UIStackView!
    @IBOutlet weak var energySegmentedControl: UISegmentedControl!
    @IBOutlet weak var durationStackView: UIStackView!
    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var createPlanButton: UIButton!

}

/*
 
 this is my vibesectionviewcontroller: UIViewController looks like:
 
label: choose your Interest
stack view:
    -stack view [button Adventure, button cultural]
    -stack view [button Foodie, button Nightlife]
    -stack view [button Relaxation, button Nature]
 
 label: Energy Level
 stack view [button Lowkey, button Balanced, button High Energy]
 
 label: Trip Duration
 stack view [button Weekend, button Week, button Exteded]
 
 label: Your Selection
  (i dont know what UI view to put but this suppose to show what user selection is from above, for ex: it will show a box with title Adventure, Low Key, Week)
 
 button: Create My Trip Plan
 */
