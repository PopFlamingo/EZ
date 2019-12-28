import NIO
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
        
        let dbContext =  DatabaseContext(configuration: configuration, logger: logger, eventLoop: el)
        self.database = sqliteDriver.makeDatabase(with: dbContext)
    }
    
    deinit {
        sqliteDriver.shutdown()
        try! elg.syncShutdownGracefully()
    }
}

extension EZDatabase: Database {
    public var context: DatabaseContext {
        self.database.context
    }
    
    public func execute(query: DatabaseQuery, onRow: @escaping (DatabaseRow) -> ()) -> EventLoopFuture<Void> {
        self.database.execute(query: query, onRow: onRow)
    }
    
    public func execute(schema: DatabaseSchema) -> EventLoopFuture<Void> {
        self.database.execute(schema: schema)
    }
    
    public func withConnection<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        self.database.withConnection(closure)
    }
}
