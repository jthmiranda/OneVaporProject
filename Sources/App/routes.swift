import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
   
    let userController = UserController()
    try router.register(collection: userController)
    
    let gameController = GamesController()
    try router.register(collection: gameController)
}
