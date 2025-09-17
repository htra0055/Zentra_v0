////
////  DatabaseProtocol.swift
////  FIT3178-W04-Lab
////
////  Created by Jason Haasz on 4/1/2023.
////
//
//import Foundation
//
//enum DatabaseChange{
//    case add
//    case remove
//    case update
//}
//
//enum ListenerType {
//    case team
//    case heroes
//    case all
//}
//
//protocol DatabaseListener: AnyObject {
//    var listenerType: ListenerType {get set}
//    func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero])
//    func onAllHeroesChange(change: DatabaseChange, heroes: [Superhero])
//}
//
//protocol DatabaseProtocol: AnyObject {
//    func cleanup()
//    
//    func addListener(listener: DatabaseListener)
//    func removeListener(listener: DatabaseListener)
//    
//    func addSuperhero(name: String, abilities:String, universe: Int) -> Superhero
//    func deleteSuperhero(hero: Superhero)
//    
//    var defaultTeam: Team {get}
//    func addTeam(teamName: String) -> Team
//    func deleteTeam(team: Team)
//    func addHeroToTeam(hero: Superhero, team: Team) -> Bool
//    func removeHeroFromTeam(hero: Superhero, team: Team)
//}
