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
        @Query var values: [FooModel]
        @Query(query: { $0.limit(10) }) var filtered: [FooModel]
    }
    
    var app: TestApp! = nil
    
    override func setUp() {
        self.app = TestApp()
        XCTAssertNoThrow(try app.configureDatabase())
    }
    
    func testExample() {
        let value = FooModel()
        value.bar = "Hey"
        
        
        let baz = Baz()
        baz.$values.objectWillChange.sink {
            print("Wow") 
        }
        XCTAssertNoThrow(try value.save(on: self.app.database).wait())
    }

    final class FooModel: Model {
        static var schema: String = "foomodel"
        @ID(key: "id", generatedBy: .database) var id: Int?
        @Field(key: "bar") var bar: String
    }
    
    final class FooMigration: Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(FooModel.schema)
                .field("id", .int, .identifier(auto: true))
                .field("bar", .string, .required)
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
