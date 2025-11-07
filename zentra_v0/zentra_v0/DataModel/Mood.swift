//
//  Mood.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//
// Acknowledgements:
//
// Libraries & SDKs:
// - UIKit (Apple) – https://developer.apple.com/documentation/uikit
//
// Purpose:
// Represents the user's selected energy/mood for a trip or plan.
// Used to filter or prioritize activities in the plan based on vibe.
//

import UIKit

/// `Mood` models the user's energy or vibe for a plan or trip.
/// - Lowkey: relaxed pace with minimal planning
/// - Balanced: mixed activities and downtime
/// - HighEnergy: packed schedule with lots of excitement
enum Mood: String, Codable {
    /// Relaxed vibe
    case Lowkey = "Lowkey vibe"
    /// Moderate, balanced vibe
    case Balanced = "Balanced vibe"
    /// High-energy, active vibe
    case HighEnergy = "High Energy"
}
