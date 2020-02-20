//
//  MoviesController.swift
//  App
//
//  Created by Jonathan Miranda on 2/14/20.
//

import Vapor
import FluentSQLite

struct MoviesController: RouteCollection {
    func boot(router: Router) throws {
        let moviesRouter = router.grouped("api", "movies")
        moviesRouter.post(Movies.self, at: "create", use: createMovie)
        moviesRouter.post(MovieUser.self, at: "addRelation", use: addMovieUser)
    }
}

func createMovie(_ req: Request, movie: Movies) throws -> Future<Movies> {
    return movie.save(on: req)
}

func addMovieUser(_ req: Request, movieUser: MovieUser) throws -> Future<HTTPStatus> {
    return flatMap(
        Users.query(on: req)
            .filter(\.userid == movieUser.user)
            .first()
            .unwrap(or: Abort(.notFound, reason: "There's no user")),
        Movies.query(on: req)
            .filter(\.title == movieUser.title)
            .first()
            .unwrap(or: Abort(.notFound, reason: "There's no movie"))) { (user, movie) in
                let pivot = try UsersMoviesPivot(user.requireID(), movie.requireID())
                return pivot.save(on: req).transform(to: .created)
    }
}

struct MovieUser: Content {
    let title: String
    let user: String
}
