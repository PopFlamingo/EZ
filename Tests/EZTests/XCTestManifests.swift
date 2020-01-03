// (c) 2019-2020 Trevör Anne Denise
// This code is licensed under MIT license (see LICENSE for details)

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(EZTests.allTests),
    ]
}
#endif
