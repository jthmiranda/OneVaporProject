//
//  UsersController.swift
//  App
//
//  Created by Jonathan Miranda on 2/10/20.
//

import Vapor
import FluentSQLite

struct UserController: RouteCollection {
    func boot(router: Router) throws {
        let userRoutes = router.grouped("api", "user")
        
        userRoutes.post(Users.self, at: "create", use: createUser)
        userRoutes.get("queryAll", use: queryAllUsers)
        userRoutes.get("query", Users.parameter, use: queryUser)
        userRoutes.post(userIDQuery.self, at: "queryUserID", use: queryUserId)
        userRoutes.get("queryUserID", use: queryUserIdGet)
        userRoutes.put(UpdateQuery.self, at: "update", use: updateUserID)
        userRoutes.put("updateID", Users.parameter, use: updateUserIDParam)
        userRoutes.delete("delete", Users.parameter, use: deleteUserIDParam)
        userRoutes.post(userIDQuery.self, at: "delete", use: deleteUserID)
    }
}


func createUser(_ req: Request, user: Users) throws -> Future<Users.Public> {
    return user.save(on: req).toPublic()
}

func queryAllUsers(_ req: Request) throws -> Future<[Users.Public]> {
    return Users.query(on: req).decode(data: Users.Public.self).all()
}

func queryUser(_ req: Request) throws -> Future<Users.Public> {
    return try req.parameters.next(Users.self).toPublic()
}

func queryUserId(_ req: Request, user: userIDQuery) throws -> Future<Users.Public> {
    return Users.query(on: req)
        .filter(\.userid == user.userID)
        .first()
        .unwrap(or: Abort(.notFound, reason: "No existe el userid proporcionado"))
        .toPublic()
}

func queryUserIdGet(_ req: Request) throws -> Future<Users.Public> {
    guard let userid = req.query[String.self, at: "userID"] else {
        throw Abort(HTTPStatus.badRequest, reason: "No existe el parámetro mensaje en la llamada")
    }
    return Users.query(on: req)
        .filter(\.userid == userid)
        .first()
        .unwrap(or: Abort(.notFound, reason: "No existe el userid proporcionado"))
        .toPublic()
}

func updateUserID(_ req: Request, update: UpdateQuery) throws -> Future<Users.Public> {
    return Users.query(on: req)
        .filter(\.userid == update.userid)
        .first()
        .unwrap(or: Abort(.notFound, reason: "No existe el userid proporcionado"))
        .flatMap { user in
            user.userid = update.newUserid
            return user.update(on: req).toPublic()
        }
}

func updateUserIDParam(_ req: Request) throws -> Future<Users.Public> {
    return try flatMap(req.parameters.next(Users.self), req.content.decode(userIDQuery.self)) { (user, new) in
        user.userid = new.userID
        return user.update(on: req).toPublic()
    }
}


// this method will be usage more often
func deleteUserIDParam(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Users.self).flatMap { user in
        return user.delete(on: req).transform(to: HTTPStatus.noContent)
    }
}

// this method got a JSON to filter the record to be deleted without key
func deleteUserID(_ req: Request, update: userIDQuery) throws -> Future<HTTPStatus> {
    return Users.query(on: req)
        .filter(\.userid == update.userID)
        .first()
        .unwrap(or: Abort(.notFound, reason: "No existe el userid proporcionado"))
        .delete(on: req).transform(to: .noContent)
    // flapMap can be avoid instead delete method straighforward
//        .flatMap { user in
//            return user.delete(on: req).transform(to: .noContent)
//        }
}

// this methos will be useful to get the param from URL instead from body post
func deleteUserIdGet(_ req: Request) throws -> Future<HTTPStatus> {
    guard let userid = req.query[String.self, at: "userID"] else {
        throw Abort(HTTPStatus.badRequest, reason: "No existe el parámetro mensaje en la llamada")
    }
    return Users.query(on: req).filter(\.userid == userid)
        .first()
        .unwrap(or: Abort(.notFound, reason: "No existe el userid proporcionado"))
        .flatMap { user in
            return user.delete(on: req).transform(to: .noContent)
        }
}

// -----------------
// struct helpers to get filter info
//

struct userIDQuery: Content {
    let userID: String
}

struct UpdateQuery: Content {
    let userid: String
    let newUserid: String
}
