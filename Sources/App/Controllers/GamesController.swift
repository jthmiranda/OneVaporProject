//
//  GamesController.swift
//  App
//
//  Created by Jonathan Miranda on 2/11/20.
//

import Vapor
import FluentSQLite

struct GamesController: RouteCollection {
    func boot(router: Router) throws {
        let gamesRoutes = router.grouped("api", "games")
        gamesRoutes.post(Games.self, at: "create", use: createGame)
        gamesRoutes.post(GameUserID.self, at: "createID", use: createGameCreateUserID)
        gamesRoutes.get("allGames", use: queryAllGames)
        gamesRoutes.post(GameUserIDQuery.self, at: "queryGame", use: queryUserGames)
        gamesRoutes.post(GameUserID.self, at: "updateGame", use: updateGamesData)
    }
}

func createGame(_ req: Request, game: Games) throws -> Future<Games> {
    game.save(on: req)
}

func createGameCreateUserID(_ req: Request, game: GameUserID) throws -> Future<Games> {
    return Users.query(on: req)
        .filter(\.userid == game.userid)
        .first()
        .unwrap(or: Abort(.notFound, reason: "User not found"))
        .flatMap { user in
            let newGame = Games(game: game.game, points: game.points, level: game.level, genre: game.genre, userid: user.id!)
            return newGame.save(on: req)
        }
}

// this allow to query the parameter in the url for example: userid=any@mail.com
func queryAllGames(_ req: Request) throws -> Future<[Games]> {
    guard let userid = req.query[String.self, at: "userid"] else {
        throw Abort(HTTPStatus.badRequest, reason: "No hay parametro userid")
    }
    return Users.query(on: req).filter(\.userid == userid).first().unwrap(or: Abort(.notFound, reason: "User not found")).flatMap { user in
        return try user.games.query(on: req).all()
    }
}

func queryUserGames(_ req: Request, query: GameUserIDQuery) throws -> Future<Games> {
    return Users.query(on: req).filter(\.userid == query.userid).first().unwrap(or: Abort(.notFound, reason: "User not found")).flatMap { user in
        return try user.games.query(on: req).filter(\.game == query.game).first().unwrap(or: Abort(.notFound, reason: "User not found"))
    }
}

func updateGamesData(_ req: Request, update: GameUserID) throws -> Future<HTTPStatus> {
    return Users.query(on: req).filter(\.userid == update.userid).first().unwrap(or: Abort(.notFound, reason: "User not found")).flatMap { user in
        return try user.games
            .query(on: req).filter(\.game == update.game)
            .first()
            .unwrap(or: Abort(.notFound, reason: "User not found"))
            .flatMap { game in
                game.level = update.level
                game.points = update.points
                return game.update(on: req).transform(to: .ok)
            }
    }
}

struct GameUserIDQuery: Content {
    var game: String
    var userid: String
}

struct GameUserID: Content {
    var game: String
    var points: Double
    var level: Int
    var genre: String
    var userid: String
}
