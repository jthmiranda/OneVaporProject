//
//  Games.swift
//  App
//
//  Created by Jonathan Miranda on 2/10/20.
//

import Vapor
import FluentPostgreSQL

final class Games {
    var id: UUID?
    var game: String
    var points: Double
    var level: Int
    var genre: String
    var userid: Users.ID
    
    init(game: String, points: Double, level: Int, genre: String, userid: Users.ID) {
        self.game = game
        self.points = points
        self.level = level
        self.genre = genre
        self.userid = userid
    }
    
    var user: Parent<Games, Users> {
        return parent(\.id!)
    }

}


extension Games: PostgreSQLUUIDModel {}
extension Games: Content {}
extension Games: Migration {}
extension Games: Parameter {}

// we can make any struct like this one to modify (ALTER) table by adding, removing, etc a field and so more.
// do not let the migration for this struct without comment after appling any modification.
struct GameUpdateGenre: PostgreSQLMigration, PostgreSQLModel {
    var id: Int?
    
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(Games.self, on: connection) { builder in
            builder.field(for: \.genre, type: PostgreSQLDataType.varchar, .default(.literal("None")))
        }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(Games.self, on: connection) { buider in
            buider.deleteField(for: \.genre)
        }
        // return connection.future() returning a empty furute when there's nothing to put back
    }
}

// We can do more operation other than altering table on database
// in this example we can make a data cleanup to reset to any state you want
struct GamePointsCleanup: PostgreSQLMigration {
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Games.query(on: conn).filter(\.points > 0).delete()
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        // because deleting data in prepare func can not be revert, it needs to return a empty future
        conn.future()
    }
    
}
