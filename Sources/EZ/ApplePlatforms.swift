#if canImport(UIKit)
import UIKit
import FluentKit

public protocol EZApp: UIApplicationDelegate {
    var database: EZDatabase { get }
    var migrations: [Migration] { get }
}

extension EZApp {
    public func configureDatabase() throws {
        let dbs = Databases(threadPool: database.threadPool, on: database.eventLoop)
        let migrationsObject = Migrations()
        for migration in self.migrations {
            migrationsObject.add(migration)
        }
        
        let migrator = Migrator(databases: dbs, migrations: migrationsObject, logger: database.logger, on: database.eventLoop)
        try migrator.setupIfNeeded().wait()
        try migrator.prepareBatch().wait()
    }
}

enum DatabasePreference {
    case ephemeral
    case file(String)
}

#endif
