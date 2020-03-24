//
//  SHARequest.swift
//  App
//
//  Created by Jonathan Miranda on 3/24/20.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Crypto

// Main key
let key = "Password12345678Password12345678" // 32 char lenght
// Initialization Vector - starting point beging cypher
let iv = "123456789012" // 12 char lenght
// Authectication Vector - is like a tag
let aauth = "DataDataDataData"  // 16 char lenght

struct JSON_AES: Content {
    let content: String
    let tag: String
}

struct SHARequest: RouteCollection {
    func boot(router: Router) throws {
        let userRouters = router.grouped("api", "secure")
        userRouters.post(JSON_AES.self, at: "query", use: userRequestSafe)
    }
    
    
}

func userRequestSafe(_ req: Request, data: JSON_AES) throws -> Future<Users.Public> {
    guard let dataContent = Data(base64Encoded: data.content), let tagData = Data(base64Encoded: data.tag) else {
        throw Abort(.badRequest, reason: "Bad Request")
    }
    
    let JSONb64 = try AES256GCM.decrypt(dataContent, key: key, iv: iv, tag: tagData).convert(to: String.self)
    
    guard let JSONData = Data(base64Encoded: JSONb64) else {
        throw Abort(.badRequest, reason: "Bad data")
    }
    
    let decoder = JSONDecoder()
    let dataJSON = try decoder.decode(userIDQuery.self, from: JSONData)
    
    
    return Users.query(on: req)
        .filter(\.userid == dataJSON.userID)
        .first()
        .unwrap(or: Abort(.notFound, reason: "Username not found"))
        .toPublic()
    
}
