//
//  Games.swift
//  App
//
//  Created by Jonathan Miranda on 2/10/20.
//

import Vapor
import FluentSQLite

final class Games {
    var id: UUID?
    var game: String
    var points: Double
    var level: Int
    var userid: Users.ID
    
    init(game: String, points: Double, level: Int, userid: Users.ID) {
        self.game = game
        self.points = points
        self.level = level
        self.userid = userid
    }
    
    var user: Parent<Games, Users> {
        return parent(\.id!)
    }

}


extension Games: SQLiteUUIDModel {}
extension Games: Content {}
extension Games: Migration {}
extension Games: Parameter {}
