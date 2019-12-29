# EZ

This is a test library to use [FluentKit](https://github.com/vapor/fluent-kit) from iOS.

⚠️ This is mostly just a quick experimentation, the performance, API, and stability isn't necesseraly optimal, it will most likely not evolve much in the future

## Package setup
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
    @Query var allValues: [FooModel]
    @Query(query: { $0.limit(10) }) var filtered: [FooModel]
    ...
}
```

Use the `query` parameter to customize the query as usual, then you can pass a binding to your query with `$yourQuery`
