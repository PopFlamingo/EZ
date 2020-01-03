// (c) 2019-2020 Trevör Anne Denise
// This code is licensed under MIT license (see LICENSE for details)

import FluentKit

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

