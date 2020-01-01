import XCTest
import FluentKit
@testable import EZ

final class EZTests: XCTestCase {
    
    class TestApp: EZApp {
        var database: EZDatabase = EZDatabase()
        
        var migrations: [Migration] = [
            FooMigration()
        ]
    }
    
    class Baz {
        @Query var allValues: [FooModel]
        @Query(\.$baz >= 20) var filtered1: [FooModel]
        @Query(\.$bar == "abc", \.$baz >= 20, limit: 100) var filtered2: [FooModel]
        @Query(limit: 100) var filtered3: [FooModel]
        @Query({ $0.limit(10) }) var customQueryBuilder: [FooModel]
    }
    
    var app: TestApp! = nil
    
    override func setUp() {
        self.app = TestApp()
        XCTAssertNoThrow(try app.configureDatabase())
    }
    
    func testExample() {
        let value = FooModel()
        value.bar = "Hey"
        value.baz = 10
        let baz = Baz()
        XCTAssertNoThrow(try value.save(on: self.app.database).wait())
        XCTAssertEqual(baz.allValues.count, 1)
    }

    final class FooModel: Model {
        static var schema: String = "foomodel"
        @ID(key: "id", generatedBy: .database) var id: Int?
        @Field(key: "bar") var bar: String
        @Field(key: "baz") var baz: Int
    }
    
    final class FooMigration: Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(FooModel.schema)
                .field("id", .int, .identifier(auto: true))
                .field("bar", .string, .required)
                .field("baz", .int, .required)
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(FooModel.schema).delete()
        }
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}
