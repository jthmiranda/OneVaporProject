//
//  Users.swift
//  App
//
//  Created by Jonathan Miranda on 2/10/20.
//

import Vapor
import FluentPostgreSQL

final class Users: Codable {
    var id: UUID?
    var userid: String
    var name: String
    var password: String
    
    init(userid: String, name: String, password: String) {
        self.userid = userid
        self.name = name
        self.password = password
    }
    
    var games: Children<Users, Games> {
        return children(\.userid)
    }
    
    var movies: Siblings<Users, Movies, UsersMoviesPivot> {
        return siblings()
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var userid: String
        
        init(id: UUID?, name: String, userid: String) {
            self.id = id
            self.name = name
            self.userid = userid
        }
    }
    
    func toPublic() -> Users.Public {
        return Users.Public(id: id, name: name, userid: userid)
    }
}

extension Users: PostgreSQLUUIDModel {}
extension Users: Migration {}
extension Users: Content {}
extension Users: Parameter {}

extension Users.Public: Content {}

extension Future where T: Users {
    func toPublic() -> Future<Users.Public> {
        return map(to: Users.Public.self) { user in
            return user.toPublic()
        }
    }
}

struct UserPassword: PostgreSQLMigration, PostgreSQLModel {
    var id: Int?
    
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(Users.self, on: connection) { builder in
            builder.field(for: \.password, type: PostgreSQLDataType.varchar, .default(.literal("")))
        }
    }
    
    static func revert(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return PostgreSQLDatabase.update(Users.self, on: connection) { builder in
            builder.deleteField(for: \.password)
        }
    }
}
