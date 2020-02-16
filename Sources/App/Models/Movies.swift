//
//  Movies.swift
//  App
//
//  Created by Jonathan Miranda on 2/14/20.
//

import Vapor
import FluentSQLite

final class Movies: Codable {
    var id: UUID?
    var title: String
    var year: Int
    var rank: Double
    
    init(title: String, year: Int, rank: Double) {
        self.title = title
        self.year = year
        self.rank = rank
    }
    
    var users: Siblings<Movies, Users, UsersMoviesPivot> {
        return siblings()
    }
}

extension Movies: SQLiteUUIDModel {}
extension Movies: Content {}
extension Movies: Parameter {}
extension Movies: Migration {}
