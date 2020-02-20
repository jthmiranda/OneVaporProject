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
        moviesRouter.get("getMoviesUser", use: queryMovieUser)
        moviesRouter.get("getUserMovies", use: queryUserMovie)
        moviesRouter.get("queryRank", use: queryRank)
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

func queryMovieUser(_ req: Request) throws -> Future<[Movies]> {
    guard let userid = req.query[String.self, at: "userid"] else {
        throw Abort(.badRequest, reason: "There's no userid")
    }
    return Users.query(on: req)
        .filter(\.userid, .like, userid)
        .first()
        .unwrap(or: Abort(.notFound, reason: "There's no user"))
        .flatMap { user in
            return try user.movies.query(on: req).all()
        }
}

func queryUserMovie(_ req: Request) throws -> Future<[Users]> {
    guard let movie = req.query[String.self, at: "movie"] else {
        throw Abort(.badRequest, reason: "There's no movie")
    }
    return Movies.query(on: req)
        .filter(\.title, .like, movie)
        .first()
        .unwrap(or: Abort(.notFound, reason: "There's no movie"))
        .flatMap { movie in
            return try movie.users.query(on: req).all()
        }
}

func queryRank(_ req: Request) throws -> Future<[Movies]> {
    return Movies
        .query(on: req)
        .group(.and) {
            $0.filter(\.rank >= 8).filter(\.rank <= 10)
        }
        .range(..<5)
        .sort(\.title, .descending)
        .all()
}

struct MovieUser: Content {
    let title: String
    let user: String
}
