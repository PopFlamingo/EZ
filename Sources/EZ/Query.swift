//
//  File.swift
//  
//
//  Created by Trevör Anne Denise on 03/01/2020.
//

import SwiftUI

@propertyWrapper
public struct Query<ModelType: FluentKit.Model>: DynamicProperty {
    @ObservedObject private var observable: ObservableQuery<ModelType>
    
    public var wrappedValue: [ModelType] {
        return observable.result
    }
    
    public init() {
        self.observable = ObservableQuery()
    }
    
    public init(_ queryModifier: ((QueryBuilder<ModelType>)->(QueryBuilder<ModelType>))? = nil, database: EZDatabase? = nil) {
        self.observable = ObservableQuery(queryModifier, database: database)
    }
    
    public init<T>(_ filters: ModelValueFilter<ModelType>..., sorter: Sorters<ModelType>.Sorter<T>? = nil, limit: Int? = nil, database: EZDatabase? = nil) {
        var sorters: Sorters<ModelType>? = nil
        if let sorter = sorter {
            sorters = Sorters(sorter)
        }
        
        self.observable = ObservableQuery(filters, sorters: sorters, limit: limit, database: database)
    }
    
    public init(_ filters: ModelValueFilter<ModelType>..., sorters: Sorters<ModelType>? = nil, limit: Int? = nil, database: EZDatabase? = nil) {
        self.observable = ObservableQuery(filters, sorters: sorters, limit: limit, database: database)
    }
    
    public init(_ filters: [ModelValueFilter<ModelType>], sorters: Sorters<ModelType>? = nil, limit: Int? = nil, database: EZDatabase? = nil) {
        self.observable = ObservableQuery(filters, sorters: sorters, limit: limit, database: database)
    }
}
