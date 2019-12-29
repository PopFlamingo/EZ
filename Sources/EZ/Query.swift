import FluentKit
import SwiftUI

@propertyWrapper
public class Query<ModelType: FluentKit.Model> {
    
    @ObservedObject var observed = ObservedQuery(value: nil)
    var specifiedDatabase: EZDatabase?
    var database: EZDatabase {
        specifiedDatabase ?? EZDatabase.shared
    }
        
    public convenience init() {
        self.init(database: nil)
    }
    
    public init(query queryModifier: ((QueryBuilder<ModelType>)->(QueryBuilder<ModelType>))? = nil, database: EZDatabase? = nil) {
        let actualModifier = queryModifier ?? { $0 }
        self.specifiedDatabase = database
        self.database.register(query: self) {
            let newValue = try! actualModifier(ModelType.query(on: self.database)).all().wait()
            print(newValue)
            self.observed.value = newValue
        }
    }
    
    deinit {
        database.deregister(query: self)
    }
    
    
    public var wrappedValue: [ModelType] {
        if let existing = observed.value {
            return existing
        } else {
            let value = try! ModelType.query(on: database).all().wait()
            observed.value = value
            return value
        }
    }
    
    class ObservedQuery: ObservableObject {
        init(value: [ModelType]?) {
            self.value = value
        }
        
        @Published var value: [ModelType]?
    }
    
}
