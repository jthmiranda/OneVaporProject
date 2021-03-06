import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
   
    let userController = UserController()
    try router.register(collection: userController)
    
    let gameController = GamesController()
    try router.register(collection: gameController)
    
    let moviesController = MoviesController()
    try router.register(collection: moviesController)
    
    let safeController = SHARequest()
    try router.register(collection: safeController)
}
