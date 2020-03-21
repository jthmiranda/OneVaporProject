//
//  Token.swift
//  App
//
//  Created by Jonathan Miranda on 3/21/20.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication
import Crypto

final class Token: Codable {
    var id: UUID?
    var token: String
    var userID: Users.ID
    
    init(token: String, userID: Users.ID) {
        self.token = token
        self.userID = userID
    }
    
    var user: Parent<Token, Users> {
        return parent(\.userID)
    }
    
    static func generate(for user: Users) throws -> Token {
        let random = try CryptoRandom().generateData(count: 32)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
}

extension Token: PostgreSQLUUIDModel {}
extension Token: Content {}
extension Token: Migration {}


extension Token: Authentication.Token {
    static var userIDKey: WritableKeyPath<Token, Users.ID> {
        \Token.userID
    }
    
    typealias UserType = Users
    
    typealias UserIDType = Users.ID
    
    static var tokenKey: WritableKeyPath<Token, String> {
        return \Token.token
    }
    
    
}
