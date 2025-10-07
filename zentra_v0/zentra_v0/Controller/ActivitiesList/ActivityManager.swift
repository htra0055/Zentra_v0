//
//  ActivityManager.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 7/10/2025.
//


import Foundation
import GooglePlaces

// MARK: - Saved Activity Model
struct SavedActivity: Identifiable, Codable {
    let id: UUID
    let name: String
    let placeID: String
    let address: String

    init(name: String, placeID: String, address: String) {
        self.id = UUID()
        self.name = name
        self.placeID = placeID
        self.address = address
    }
}

// MARK: - Saved Activity List
struct ActivityList: Identifiable, Codable {
    let id: UUID
    var name: String
    var activities: [SavedActivity]

    init(name: String, activities: [SavedActivity] = []) {
        self.id = UUID()
        self.name = name
        self.activities = activities
    }
}

// MARK: - Activity Manager
class ActivityManager {
    static let shared = ActivityManager()

    private var userLists: [ActivityList] = []

    private init() {
        loadLists()
    }

    // MARK: - Persistence
    private func saveLists() {
        if let data = try? JSONEncoder().encode(userLists) {
            UserDefaults.standard.set(data, forKey: "userLists")
        }
    }

    private func loadLists() {
        if let data = UserDefaults.standard.data(forKey: "userLists"),
           let decoded = try? JSONDecoder().decode([ActivityList].self, from: data) {
            userLists = decoded
        }
    }

    // MARK: - Public API

    func getUserLists() -> [ActivityList] {
        return userLists
    }

    @discardableResult
    func createList(name: String) -> ActivityList {
        let newList = ActivityList(name: name)
        userLists.append(newList)
        saveLists()
        return newList
    }

    func addActivity(place: GMSPlace, toList list: ActivityList) {
        guard let index = userLists.firstIndex(where: { $0.id == list.id }) else { return }
        let activity = SavedActivity(
            name: place.name ?? "Unknown Place",
            placeID: place.placeID ?? "",
            address: place.formattedAddress ?? ""
        )
        userLists[index].activities.append(activity)
        saveLists()
    }

    func saveActivities(places: [GMSPlace]) {
        let defaultListName = "Saved Activities"
        if !userLists.contains(where: { $0.name == defaultListName }) {
            createList(name: defaultListName)
        }
        guard let list = userLists.first(where: { $0.name == defaultListName }) else { return }
        for place in places {
            addActivity(place: place, toList: list)
        }
    }
    
    func updateList(_ list: ActivityList) {
        if let index = userLists.firstIndex(where: { $0.id == list.id }) {
            userLists[index] = list
            saveLists()   // Persist changes
        }
    }
    
    func deleteList(_ list: ActivityList) {
        // Remove from local array
        userLists.removeAll { $0.id == list.id }
        
        // Persist the change
        saveLists()   // <-- use the existing saveLists() method
    }

    



    
    
}
