import NIO
import FluentKit
import FluentSQLiteDriver

public class FluentSQLiteDatabase {
    let elg: EventLoopGroup
    public let database: Database
    let sqliteDriver: DatabaseDriver
    
    init(file: String? = nil) {
        self.elg = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let el = self.elg.next()
        let dbs = Databases(threadPool: NIOThreadPool(numberOfThreads: 1), on: el)
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
