import FluentKit
import SwiftUI

@propertyWrapper
public struct Query<ModelType: FluentKit.Model>: DynamicProperty {
    
    @ObservedObject var observed: ObservedQuery
    var specifiedDatabase: EZDatabase?
    var database: EZDatabase {
        specifiedDatabase ?? EZDatabase.shared
    }
    let dependencies: Set<String>
        
    public init() {
        self.init(database: nil)
    }
    
    public init(_ queryModifier: ((QueryBuilder<ModelType>)->(QueryBuilder<ModelType>))? = nil, database: EZDatabase? = nil) {
        let newQuery = ModelType.query(on: database ?? EZDatabase.shared)
        let actualQuery = queryModifier?(newQuery) ?? newQuery
        self.specifiedDatabase = database
        let someObserved = ObservedQuery(value: nil)
        self.observed = someObserved
        var schemas = [ModelType.schema] as Set
        
        for join in actualQuery.query.joins.map({ $0 }) {
            switch join {
            case .custom(_):
                //FIXME: What to do in this case?
                break
            case .join(schema: let schema, foreign: _, local: _, method: _):
                switch schema {
                case .schema(let name, let alias):
                    schemas.insert(name)
                    //FIXME: What's an alias exactly
                    if let alias = alias {
                        schemas.insert(alias)
                    }
                case .custom(_):
                    //FIXME: What to do in this case?
                    break
                }
                
            }
        }
        
        let mirror = Mirror(reflecting: ModelType.init())
        for childProperty in mirror.children {
            if let property = childProperty.value as? DependencySpecifier {
                for dependency in property.dependencies {
                    schemas.insert(dependency)
                }
            }
        }
        
        print("Detected dependencies for \(type(of: self)) are \(schemas)")
        
        self.dependencies = schemas
        
        self.database.register(query: self) {
            let newValue = try! actualQuery.all().wait()
            someObserved.value = newValue
        }
    }
    
    public init<T>(_ filters: ModelValueFilter<ModelType>..., sorter: Sorters<ModelType>.Sorter<T>? = nil, limit: Int? = nil, database: EZDatabase? = nil) {
        if let sorter = sorter {
            self.init(filters, sorters: Sorters(sorter), limit: limit, database: database)
        } else {
            self.init(filters, sorters: nil, limit: limit, database: database)
        }
        
    }
    
    public init(_ filters: ModelValueFilter<ModelType>..., sorters: Sorters<ModelType>? = nil, limit: Int? = nil, database: EZDatabase? = nil) {
        self.init(filters, sorters: sorters, limit: limit, database: database)
    }
    
    public init(_ filters: [ModelValueFilter<ModelType>], sorters: Sorters<ModelType>? = nil, limit: Int? = nil, database: EZDatabase? = nil) {
        let modifier: (QueryBuilder<ModelType>)->(QueryBuilder<ModelType>) = { query in
            var modifiedQuery = query
            for filter in filters {
                modifiedQuery = modifiedQuery.filter(filter)
            }
            
            if let sorters = sorters {
                modifiedQuery = sorters.transform(modifiedQuery)
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



public struct Sorters<ModelType: FluentKit.Model> {
    
    public typealias Sorter<T: Codable> = (KeyPath<ModelType, Field<T>>, SortDescriptorOperator)
    
    public init<T>(_ s1: Sorter<T>) {
        self.transform = { builder in
            builder.sort(s1.0, s1.1((),()))
        }
    }
    
    public init<T, U>(_ s1: Sorter<T>, _ s2: Sorter<U>) {
        self.transform = { builder in
            builder
                .sort(s1.0, s1.1((),()))
                .sort(s2.0, s2.1((),()))
        }
    }
    
    public init<T, U, V>(_ s1: Sorter<T>, _ s2: Sorter<U>, _ s3: Sorter<V>) {
        self.transform = { builder in
            builder
                .sort(s1.0, s1.1((),()))
                .sort(s2.0, s2.1((),()))
                .sort(s3.0, s3.1((),()))
        }
    }
    
    public init<T, U, V, W>(_ s1: Sorter<T>, _ s2: Sorter<U>, _ s3: Sorter<V>, _ s4: Sorter<W>) {
        self.transform = { builder in
            builder
                .sort(s1.0, s1.1((),()))
                .sort(s2.0, s2.1((),()))
                .sort(s3.0, s3.1((),()))
                .sort(s4.0, s4.1((),()))
        }
    }
    
    let transform: (QueryBuilder<ModelType>)->(QueryBuilder<ModelType>)

}

public typealias SortDescriptorOperator = (Void, Void) -> DatabaseQuery.Sort.Direction

public func <(lhs: Void, rhs: Void) -> DatabaseQuery.Sort.Direction {
    .ascending
}

public func >(lhs: Void, rhs: Void) -> DatabaseQuery.Sort.Direction {
    .descending
}
