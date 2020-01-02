# EZ

This is a test library to use [FluentKit](https://github.com/vapor/fluent-kit) from iOS.

⚠️ This is mostly just a quick experimentation, the performance, API, and stability isn't necesseraly optimal, it will most likely not evolve much in the future

## Package setup
### Apple platforms Xcode projects
Add a package dependency to `https://github.com/adtrevor/ez.git`, and depend on the `master` branch, you can then simply `import EZ`

### Swift Package Manager
Add this dependency to your package:
```swift
.package(url: "https://github.com/adtrevor/ez.git", .branch("master"))
```

And add `"EZ"` to the dependencies of the target where you want to add this, you can then simply `import EZ`.


## Fluent
Create your Fluent `Model`s and `Migration`s as you normally would, note you shouldn't have to `import EZ` also imports FluentKit so you shouldn't have to directly import it.

## iOS app setup
Conform your iOS application delegate to `EZApp`, you must implement two properties: `database` and `migrations`.

### The database property
The `database` property is of `EZDatabase` type, you can initialize it as:
- `EZDatabase()` if you want an ephermeral in memory database.
- `EZDatabase(file: "path/to/sqlite/db")` to use a persistent file.

### The migrations property
This is an array containing all of your `Migration`s 

### Setup the database
Simply call `self.configureDatabase()` from your application delegate:
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    self.configureDatabase()
}
```

## Using EZ
### From UIKit
Use `Fluent` as usual, you can access to `EZDatabase` from anywhere with `EZDatabase.shared`, note that `EZDatabase` conforms to Fluent's `Database` protocol.

### From SwiftUI
Use `Fluent` as usual, additionally you can use the `Query` property wrapper like this:
```swift
struct SomeView: View {
    ...
    /// All values of FooModel
    @Query var allValues: [FooModel]
    
    /// FooModel values that match the filters
    @Query(\.$bar == "abc", \.$baz <= 25) var filtered: [FooModel]
    
    /// Filters and limits the number of values
    @Query(\.$bar == "abc", limit: 10) var filteredAndLimited: [FooModel]
    
    /// Limits the number of values
    @Query(limit: 10) var limited: [FooModel]
    
    /// All of the FooModel values, sorted by the bar property in ascending order
    @Query(sorter: (\.$bar, >)) var sortedByAscendingBar: [FooModel]
    
    /// All of the FooModel values, sorted by ascending bar and descending baz
    @Query(sorters: Sorters((\.$bar, >), (\.$baz, <)) var sortedByAscBarDescBaz: [FooModel]
    
    /// Filter, sorter and limit combined
    @Query(\.$bar == "abc", sorter: (\.$bar, >), limit: 100) var filterSortLimit: [FooModel]
    
    /// A custom QueryBuilder that lets use Fluent as usual
    /// This also gives access to features not directly supported
    /// by the `Query` initializer such as joins and more
    @Query({
        $0
            .filter(\.$bar == "abc")
            .filter(\.$baz < 20)
            .filter(\.$baz >= 10)
            .sort(\.$bar, .descending)
            .sort(\.$baz, .ascending)
            .limit(100)
    }) var customQueryBuilder: [FooModel]
    
    /// A complex query over multiples lines
    @Query(
        \.$bar == "abc",
        \.$baz < 20,
        \.$baz >= 10,
        sorters: Sorters((\.$bar, >), (\.$baz, <)),
        limit: 100
    ) var complexQuery: [FooModel]
    ...
}
```

The views will automatically update with the content of your `@Query` properties when there are changes to your models rows
