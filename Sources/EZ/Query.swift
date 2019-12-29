import FluentKit
import SwiftUI

@propertyWrapper
public class Query<ModelType: FluentKit.Model>: ObservableObject {
    
    var specifiedDatabase: EZDatabase?
    var database: EZDatabase {
        specifiedDatabase ?? EZDatabase.shared!
    }
    
    public convenience init() {
        self.init(database: nil)
    }
    
    public init(query queryModifier: ((QueryBuilder<ModelType>)->(QueryBuilder<ModelType>))? = nil, database: EZDatabase? = nil) {
        let actualModifier = queryModifier ?? { $0 }
        self.specifiedDatabase = database
        self.database.register(query: self) {
            self.internalValue = try! actualModifier(ModelType.query(on: self.database)).all().wait()
        }
    }
    
    deinit {
        database.deregister(query: self)
    }
    
    var internalValue: [ModelType]? = nil {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    public var wrappedValue: [ModelType] {
        if let existing = internalValue {
            return existing
        } else {
            let value = try! ModelType.query(on: database).all().wait()
            internalValue = value
            return value
        }
    }
    
    public var projectedValue: Query<ModelType> {
        return self
    }
    
}
