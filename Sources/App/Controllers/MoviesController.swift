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
    }
}

func createMovie(_ req: Request, movie: Movies) throws -> Future<Movies> {
    return movie.save(on: req)
}
