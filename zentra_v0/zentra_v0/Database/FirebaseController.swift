////
////  FirebaseController.swift
////  FIT3178-W04-Lab
////
////  Created by Evelyn Tran on 7/9/2025.
////
//
//
//import Foundation
////import FirebaseCore
//import FirebaseAuth
//import FirebaseFirestore
//
//class FirebaseController: NSObject, DatabaseProtocol {
//    
//    // MARK: - Properties
//    let DEFAULT_TEAM_NAME = "Default Team"
//    
//    var heroListener: ListenerRegistration?
//    var listeners = MulticastDelegate<DatabaseListener>()
//    
//    var heroList: [Superhero]
//    var defaultTeam: Team
//    
//    var authController: Auth
//    var database: Firestore
//    var heroesRef: CollectionReference?
//    var teamsRef: CollectionReference?
//    var currentUser: FirebaseAuth.User?
//    
//    
//    // task 3
//    var userHeroesRef: CollectionReference?
//    var userTeamsRef: CollectionReference?
//    var defaultHeroesRef: CollectionReference? // points to global default heroes
//
//
//    
//    // MARK: - Initialiser
//    override init() {
//        FirebaseApp.configure()
//        authController = Auth.auth()
//        database = Firestore.firestore()
//        
//        heroList = [Superhero]()
//        defaultTeam = Team()
//        
//        super.init()
//    
//    }
//    
//    // MARK: method to handle login/signup
//    func startDatabase(for user: FirebaseAuth.User) {
//        self.currentUser = user
////        self.setupHeroListener()
////        self.setupTeamListener(for: user)
////
//        // Task 3
//        // Reference the user-specific collections
//         userHeroesRef = database.collection("users").document(user.uid).collection("superheroes")
//         userTeamsRef = database.collection("users").document(user.uid).collection("teams")
//       
//        
//        // Default heroes (shared globally)
//          defaultHeroesRef = database.collection("superheroes")
//        
//         setupUserTeamIfNeeded()
//
//         // Listen to heroes for this user
//         setupHeroListeners()
//        
//    }
//    
//    // MARK: Setup default team if not exists
//    func setupUserTeamIfNeeded() {
//        guard let teamsRef = userTeamsRef else { return }
//
//        teamsRef.whereField("name", isEqualTo: DEFAULT_TEAM_NAME).getDocuments { snapshot, error in
//            if let snapshot = snapshot, snapshot.documents.isEmpty {
//                // Create default team for the user
//                _ = self.addTeam(teamName: self.DEFAULT_TEAM_NAME)
//            }
//        }
//    }
//
//
//
//
//    
//    // MARK: - DatabaseController Methods
//    func addListener(listener: DatabaseListener) {
//        listeners.addDelegate(listener)
//        
//        if listener.listenerType == .team || listener.listenerType == .all {
//            listener.onTeamChange(change: .update, teamHeroes: defaultTeam.heroes)
//        }
//        
//        if listener.listenerType == .heroes || listener.listenerType == .all {
//            listener.onAllHeroesChange(change: .update, heroes: heroList)
//        }
//    }
//    
//    func removeListener(listener: DatabaseListener) {
//        listeners.removeDelegate(listener)
//    }
//    
//    func addSuperhero(name: String, abilities: String, universe: Int) -> Superhero {
//        let hero = Superhero()
//        hero.name = name
//        hero.abilities = abilities
//        hero.universe = universe
//        
//        do {
//            if let heroRef = try userHeroesRef?.addDocument(from: hero) {
//                hero.id = heroRef.documentID
//            }
//        } catch {
//            print("Failed to serialize hero: \(error)")
//        }
//        
//        return hero
//    }
//    
//    func addTeam(teamName: String) -> Team {
//        let team = Team()
//        team.name = teamName
//        
//        if let teamRef = userTeamsRef?.addDocument(data: ["name" : teamName]) {
//            team.id = teamRef.documentID
//        }
//        
//        return team
//    }
//    
//    
//    func addHeroToTeam(hero: Superhero, team: Team) -> Bool {
//        guard let heroID = hero.id, let teamID = team.id, let teamsRef = userTeamsRef else { return false }
//
//        // Count only user-created heroes already in the team
// //       let userHeroCount = team.heroes.filter { $0.isUserCreated }.count
////        if hero.isUserCreated && userHeroCount >= 6 {
////            print("Party full: cannot add more user-created members")
////            return false
////        }
//
//        // Determine Firestore reference based on hero type
//        let heroRef = hero.isUserCreated ? userHeroesRef?.document(heroID) : defaultHeroesRef?.document(heroID)
//        guard let newHeroRef = heroRef else { return false }
//
//        // Add hero reference to the team in Firestore
//        teamsRef.document(teamID).updateData(
//            ["heroes": FieldValue.arrayUnion([newHeroRef])]
//        )
//
//        return true
//    }
//
//
//
//    func deleteSuperhero(hero: Superhero) {
//        if hero.isUserCreated, let heroID = hero.id {
//            userHeroesRef?.document(heroID).delete()
//        }
//    }
//
//    
//    func deleteTeam(team: Team) {
//        if let teamID = team.id {
//            teamsRef?.document(teamID).delete()
//        }
//    }
//    
//    func removeHeroFromTeam(hero: Superhero, team: Team) {
//        if team.heroes.contains(hero), let teamID = team.id, let heroID = hero.id {
//            if let removedHeroRef = heroesRef?.document(heroID) {
//                teamsRef?.document(teamID).updateData(
//                    ["heroes": FieldValue.arrayRemove([removedHeroRef])]
//                )
//            }
//        }
//    }
//    
//    func cleanup() {
//        // No cleanup required for Firebase
//    }
//    
//    // MARK: - Firebase Controller Specific Methods
//    func getHeroByID(_ id: String) -> Superhero? {
//        for hero in heroList {
//            if hero.id == id {
//                return hero
//            }
//        }
//        return nil
//    }
//    
//    
////    func setupHeroListener() {
////        guard let heroesRef = userHeroesRef else { return }
////
////        // Remove old listener if exists
////        heroListener?.remove()
////
////        heroListener = heroesRef.addSnapshotListener { [weak self] snapshot, error in
////            guard let self = self else { return }
////
////            guard let snapshot = snapshot else {
////                print("Failed to fetch documents: \(String(describing: error))")
////                return
////            }
////
////            self.parseHeroesSnapshot(snapshot: snapshot)
////        }
////    }
//    
//    func setupHeroListeners() {
//        // Remove previous listener
//        heroListener?.remove()
//
//        heroListener = defaultHeroesRef?.addSnapshotListener { [weak self] snapshot, error in
//            self?.handleHeroSnapshot(snapshot, isDefault: true)
//        }
//
//        _ = userHeroesRef?.addSnapshotListener { [weak self] snapshot, error in
//            self?.handleHeroSnapshot(snapshot, isDefault: false)
//        }
//    }
//
//
//    
//    func handleHeroSnapshot(_ snapshot: QuerySnapshot?, isDefault: Bool) {
//        guard let snapshot = snapshot else { return }
//
//        snapshot.documentChanges.forEach { change in
//            guard var hero = try? change.document.data(as: Superhero.self) else { return }
//            hero.isUserCreated = !isDefault
//
//            switch change.type {
//            case .added:
//                if !heroList.contains(where: { $0.id == hero.id }) {
//                    heroList.insert(hero, at: Int(change.newIndex))
//                }
//            case .modified:
//                if let index = heroList.firstIndex(where: { $0.id == hero.id }) {
//                    heroList[index] = hero
//                }
//            case .removed:
//                if let index = heroList.firstIndex(where: { $0.id == hero.id }) {
//                    heroList.remove(at: index)
//                }
//            }
//        }
//
//        listeners.invoke { listener in
//            if listener.listenerType == .heroes || listener.listenerType == .all {
//                listener.onAllHeroesChange(change: .update, heroes: heroList)
//            }
//        }
//    }
//
// 
//    
//    func setupTeamListener(for user: FirebaseAuth.User) {
//        let userDoc = database.collection("users").document(user.uid)
//        userTeamsRef = userDoc.collection("teams")
//        
//        userTeamsRef?.whereField("name", isEqualTo: DEFAULT_TEAM_NAME)
//            .addSnapshotListener { querySnapshot, error in
//                guard let querySnapshot = querySnapshot else {
//                    print("Error fetching teams: \(String(describing: error))")
//                    return
//                }
//                
//                if querySnapshot.documents.isEmpty {
//                    // Create a default team if it doesn't exist
//                    let newTeam = self.addTeam(teamName: self.DEFAULT_TEAM_NAME)
//                    self.defaultTeam = newTeam
//                } else {
//                    if let teamSnapshot = querySnapshot.documents.first {
//                        self.parseTeamSnapshot(snapshot: teamSnapshot)
//                    }
//                }
//            }
//    }
//
//    
//    func parseHeroesSnapshot(snapshot: QuerySnapshot) {
//        snapshot.documentChanges.forEach { (change) in
//            var hero: Superhero
//            do {
//                hero = try change.document.data(as: Superhero.self)
//            } catch {
//                fatalError("Unable to decode hero: \(error.localizedDescription)")
//            }
//            
//            switch change.type {
//                   case .added:
//                       if !heroList.contains(where: { $0.id == hero.id }) {
//                           heroList.insert(hero, at: Int(change.newIndex))
//                       }
//                   case .modified:
//                       if let oldIndex = heroList.firstIndex(where: { $0.id == hero.id }) {
//                           heroList.remove(at: oldIndex)
//                           heroList.insert(hero, at: Int(change.newIndex))
//                       }
//                   case .removed:
//                       if let oldIndex = heroList.firstIndex(where: { $0.id == hero.id }) {
//                           heroList.remove(at: oldIndex)
//                       }
//                   }
//            
//            
//        }
//        
//        listeners.invoke { (listener) in
//            if listener.listenerType == .heroes || listener.listenerType == .all {
//                listener.onAllHeroesChange(change: .update, heroes: self.heroList)
//            }
//        }
//    }
//    
//
//    
//    func parseTeamSnapshot(snapshot: QueryDocumentSnapshot) {
//        defaultTeam = Team()
//        defaultTeam.name = snapshot.data()["name"] as? String
//        defaultTeam.id = snapshot.documentID
//        defaultTeam.heroes.removeAll()
//
//        if let heroReferences = snapshot.data()["heroes"] as? [DocumentReference] {
//            for reference in heroReferences {
//                if let hero = getHeroByID(reference.documentID) {
//                    defaultTeam.heroes.append(hero)
//                }
//            }
//        }
//
//        listeners.invoke { listener in
//            if listener.listenerType == .team || listener.listenerType == .all {
//                listener.onTeamChange(change: .update, teamHeroes: self.defaultTeam.heroes)
//            }
//        }
//    }
//
//    
//    
//    func logout(completion: @escaping (Error?) -> Void) {
//        do {
//            try authController.signOut()
//            self.currentUser = nil
//            self.heroList.removeAll()
//            self.defaultTeam = Team()
//            self.heroListener?.remove()
//            self.heroListener = nil
//            completion(nil)
//        } catch let error {
//            completion(error)
//        }
//    }
//
//}
