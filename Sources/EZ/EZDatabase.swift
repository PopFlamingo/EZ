import NIO
import Foundation
import FluentKit
import FluentSQLiteDriver

public class EZDatabase {
    let threadPool: NIOThreadPool
    let elg: EventLoopGroup
    public let database: Database
    let sqliteDriver: DatabaseDriver
    let dbs: Databases
    
    public init(file: String? = nil) {
        self.elg = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.threadPool = NIOThreadPool(numberOfThreads: 1)
        let el = self.elg.next()
        self.dbs = Databases(threadPool: self.threadPool, on: el)
        let configuration = DatabaseConfiguration()
        let logger = Logger(label: "fluentdb")
        
        
        if let file = file {
            sqliteDriver = DatabaseDriverFactory.sqlite(file: file).makeDriver(dbs)
        } else {
            sqliteDriver = DatabaseDriverFactory.sqlite().makeDriver(dbs)
        }
        
        dbs.use(sqliteDriver, as: .sqlite, isDefault: true)
        
        let dbContext =  DatabaseContext(configuration: configuration, logger: logger, eventLoop: el)
        self.database = sqliteDriver.makeDatabase(with: dbContext)
    }
    
    deinit {
        sqliteDriver.shutdown()
        try! elg.syncShutdownGracefully()
    }
    
    static var _shared: EZDatabase? = nil
    public static var shared: EZDatabase {
        return EZDatabase._shared!
    }
    
    var changeListeners: [ListenerKey:()->()] = [:]
    
    struct ListenerKey: Hashable {
        var schema: String
        var objectID: ObjectIdentifier
    }
    
    func register<ModelType: Model>(query: Query<ModelType>, action: @escaping ()->()) {
        for schema in query.dependencies {
            let key = ListenerKey(schema: schema, objectID: ObjectIdentifier(query.observedQuery))
            self.changeListeners[key] = action
        }
    }
    
    func deregister<ModelType: Model>(query: Query<ModelType>) {
        for schema in query.dependencies {
            let key = ListenerKey(schema: schema, objectID: ObjectIdentifier(query.observedQuery))
            self.changeListeners[key] = nil
        }
    }
}

extension EZDatabase: Database {
    public var context: DatabaseContext {
        self.database.context
    }
    
    public func execute(query: DatabaseQuery, onRow: @escaping (DatabaseRow) -> ()) -> EventLoopFuture<Void> {
        
        return self.database.execute(query: query, onRow: onRow).map {
            switch query.action {
            case .create, .delete, .update, .custom(_):
                for (key, action) in self.changeListeners where key.schema == query.schema {
                    // FIXME: Is this correct?
                    DispatchQueue.main.async {
                        action()
                    }
                }
            default:
                break
            }
        }
    }
    
    public func execute(schema: DatabaseSchema) -> EventLoopFuture<Void> {
        return self.database.execute(schema: schema)
    }
    
    public func withConnection<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        return self.database.withConnection(closure)
    }
}
