//
//  UsersMoviesPivot.swift
//  App
//
//  Created by Jonathan Miranda on 2/14/20.
//

import Vapor
import FluentPostgreSQL

final class UsersMoviesPivot: PostgreSQLUUIDPivot {
    var id: UUID?
    var userID: Users.ID
    var moviesID: Movies.ID
    
    typealias Left = Users
    typealias Right = Movies
    
    static let leftIDKey: LeftIDKey = \.userID
    static let rightIDKey: RightIDKey = \.moviesID
    
    init(_ userID: Users.ID, _ moviesID: Movies.ID) {
        self.userID = userID
        self.moviesID = moviesID
    }
}

extension UsersMoviesPivot: Migration {}
