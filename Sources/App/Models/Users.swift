//
//  Users.swift
//  App
//
//  Created by Jonathan Miranda on 2/10/20.
//

import Vapor
import FluentSQLite

final class Users: Codable {
    var id: UUID?
    var userid: String
    var name: String
    
    init(userid: String, name: String) {
        self.userid = userid
        self.name = name
    }
    
    var games: Children<Users, Games> {
        return children(\.userid)
    }
    
    var movies: Siblings<Users, Movies, UsersMoviesPivot> {
        return siblings()
    }
    
}

extension Users: SQLiteUUIDModel {}
extension Users: Migration {}
extension Users: Content {}
extension Users: Parameter {}
