//
//  FirestoreActivityList.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 23/10/2025.
//

import Foundation
import FirebaseFirestore


struct FirestoreActivityItem: Codable {
    let name: String
    let placeID: String
    let address: String
    let type: String?
}
