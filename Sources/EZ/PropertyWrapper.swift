import FluentKit
import SwiftUI

@propertyWrapper
public class Query<ModelType: FluentKit.Model>: ObservableObject {
    
    var specifiedDatabase: EZDatabase?
    var database: EZDatabase {
        specifiedDatabase ?? EZDatabase.shared!
    }
    
    public init(database: EZDatabase? = nil) {
        self.specifiedDatabase = database
        self.database.register(query: self) {
            print("Change detected")
        }
    }
    
    deinit {
        database.deregister(query: self)
    }
    
    public var wrappedValue: [ModelType] {
        get {
            try! Array(ModelType.query(on: database).all().wait())
        }
    }
    
}

final class Foo: Model {
    var id: Int? = 0
    
    typealias IDValue = Int
    
    static var schema: String = ""
    
    
}

struct Lol {
    @Query var foo: [Foo]
}
