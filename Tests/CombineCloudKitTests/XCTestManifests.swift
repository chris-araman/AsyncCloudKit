import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    [
      testCase(CombineCloudKitTests.allTests)
    ]
  }
#endif
