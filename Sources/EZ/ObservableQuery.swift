import FluentKit
import Combine

public class ObservableQuery<ModelType: FluentKit.Model>: ObservableObject {
    @Published private var _result: [ModelType]? = nil
    var result: [ModelType] {
        if let existing = _result {
            return existing
        } else {
            let value = try! ModelType.query(on: database).all().wait()
            _result = value
            return value
        }
    }
    
    var specifiedDatabase: EZDatabase?
    var database: EZDatabase {
        specifiedDatabase ?? EZDatabase.shared
    }
    let dependencies: Set<String>
        
    public convenience init() {
        self.init(database: nil)
    }
    
    public init(_ queryModifier: ((QueryBuilder<ModelType>)->(QueryBuilder<ModelType>))? = nil, database: EZDatabase? = nil) {
        let emptyQueryBuilder = ModelType.query(on: database ?? EZDatabase.shared)
        let queryBuilder = queryModifier?(emptyQueryBuilder) ?? emptyQueryBuilder
        self.specifiedDatabase = database
        var dependenciesSchemas = [ModelType.schema] as Set
        
        for join in queryBuilder.query.joins.map({ $0 }) {
            switch join {
            case .custom(_):
                assertionFailure(ErrorMessages.customSQLError)
            case .join(schema: let schema, foreign: _, local: _, method: _):
                switch schema {
                case .schema(let name, let alias):
                    dependenciesSchemas.insert(name)
                    //FIXME: What's an alias exactly
                    if let alias = alias {
                        dependenciesSchemas.insert(alias)
                    }
                case .custom(_):
                    assertionFailure(ErrorMessages.customSQLError)
                    break
                }
            }
        }
        
        let modelMirror = Mirror(reflecting: ModelType.init())
        for property in modelMirror.children {
            if let property = property.value as? DependencySpecifier {
                for dependency in property.dependencies {
                    dependenciesSchemas.insert(dependency)
                }
            }
        }
        
        self.dependencies = dependenciesSchemas
        
        self.database.register(query: self) {
            self._result = try! queryBuilder.all().wait()
        }
    }
    
    public convenience init<T>(_ filters: ModelValueFilter<ModelType>..., sorter: Sorters<ModelType>.Sorter<T>? = nil, limit: Int? = nil, database: EZDatabase? = nil) {
        if let sorter = sorter {
            self.init(filters, sorters: Sorters(sorter), limit: limit, database: database)
        } else {
            self.init(filters, sorters: nil, limit: limit, database: database)
        }
        
    }
    
    public convenience init(_ filters: ModelValueFilter<ModelType>..., sorters: Sorters<ModelType>? = nil, limit: Int? = nil, database: EZDatabase? = nil) {
        self.init(filters, sorters: sorters, limit: limit, database: database)
    }
    
    public convenience init(_ filters: [ModelValueFilter<ModelType>], sorters: Sorters<ModelType>? = nil, limit: Int? = nil, database: EZDatabase? = nil) {
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
    
}
