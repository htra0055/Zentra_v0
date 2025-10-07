//
//  FriendManager.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 7/10/2025.
//

import Foundation
import GooglePlaces

class FriendManager {
    static let shared = FriendManager()

    private var friends: [String] = ["alice@example.com", "bob@example.com", "carol@example.com"]
    private var sharedActivities: [String: [GMSPlace]] = [:] // friendEmail : activities

    func getFriends() -> [String] {
        return friends
    }

    func addFriend(_ email: String) {
        guard !friends.contains(email) else { return }
        friends.append(email)
    }

    func shareActivities(_ activities: [GMSPlace], with friend: String) {
        if sharedActivities[friend] == nil {
            sharedActivities[friend] = []
        }
        sharedActivities[friend]?.append(contentsOf: activities)
        print("Shared \(activities.count) activities with \(friend)")
    }

    func getSharedActivities(for friend: String) -> [GMSPlace] {
        return sharedActivities[friend] ?? []
    }
}
