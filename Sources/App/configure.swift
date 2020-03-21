import FluentPostgreSQL
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)


    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "postgres", database: "holaVaporTest", password: "sw1ftRules")
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Users.self, database: .psql)
    migrations.add(model: Games.self, database: .psql)
    migrations.add(model: Movies.self, database: .psql)
    migrations.add(model: UsersMoviesPivot.self, database: .psql)
//    After applying a modification please remove the line or keep it commented
//    migrations.add(model: GameUpdateGenre.self, database: .psql)
//    migrations.add(model: UserPassword.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    services.register(migrations)
}
