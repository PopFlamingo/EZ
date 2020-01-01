import FluentKit
import SwiftUI

@propertyWrapper
public struct Query<ModelType: FluentKit.Model>: DynamicProperty {
    
    @ObservedObject var observed: ObservedQuery
    var specifiedDatabase: EZDatabase?
    var database: EZDatabase {
        specifiedDatabase ?? EZDatabase.shared
    }
        
    public init() {
        self.init(database: nil)
    }
    
    public init(_ queryModifier: ((QueryBuilder<ModelType>)->(QueryBuilder<ModelType>))? = nil, database: EZDatabase? = nil) {
        let actualModifier = queryModifier ?? { $0 }
        self.specifiedDatabase = database
        let someObserved = ObservedQuery(value: nil)
        self.observed = someObserved
        self.database.register(query: self) {
            let newValue = try! actualModifier(ModelType.query(on: database ?? EZDatabase.shared)).all().wait()
            someObserved.value = newValue
        }
    }
    
    public init(_ filters: ModelValueFilter<ModelType>..., limit: Int? = nil, database: EZDatabase? = nil) {
        let modifier: (QueryBuilder<ModelType>)->(QueryBuilder<ModelType>) = { query in
            var modifiedQuery = query
            for filter in filters {
                modifiedQuery = modifiedQuery.filter(filter)
            }
            if let limit = limit {
                modifiedQuery = modifiedQuery.limit(limit)
            }
            return modifiedQuery
        }
        self.init(modifier, database: database)
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
