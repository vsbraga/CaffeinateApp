import Foundation

// MARK: - Minimal Test Framework

var totalTests = 0
var totalPassed = 0
var totalFailed = 0
var failedTests: [String] = []
var currentSuite = ""

struct AssertionError: Error {
    let message: String
}

func describe(_ name: String, _ block: () -> Void) {
    currentSuite = name
    print("--- \(name) ---")
    block()
    print()
}

func it(_ name: String, _ block: () throws -> Void) {
    totalTests += 1
    do {
        try block()
        totalPassed += 1
        print("  PASS  \(name)")
    } catch let error as AssertionError {
        totalFailed += 1
        failedTests.append("\(currentSuite) > \(name): \(error.message)")
        print("  FAIL  \(name)")
        print("         -> \(error.message)")
    } catch {
        totalFailed += 1
        failedTests.append("\(currentSuite) > \(name): \(error)")
        print("  FAIL  \(name)")
        print("         -> \(error)")
    }
}

func assertEqual<T: Equatable>(_ a: T, _ b: T, _ msg: String = "") throws {
    if a != b {
        let detail = msg.isEmpty ? "Expected \(b), got \(a)" : msg
        throw AssertionError(message: detail)
    }
}

func assertTrue(_ value: Bool, _ msg: String = "") throws {
    if !value {
        let detail = msg.isEmpty ? "Expected true, got false" : msg
        throw AssertionError(message: detail)
    }
}

func assertFalse(_ value: Bool, _ msg: String = "") throws {
    try assertTrue(!value, msg.isEmpty ? "Expected false, got true" : msg)
}

func assertNil<T>(_ value: T?, _ msg: String = "") throws {
    if value != nil {
        let detail = msg.isEmpty ? "Expected nil" : msg
        throw AssertionError(message: detail)
    }
}

func assertNotNil<T>(_ value: T?, _ msg: String = "") throws {
    if value == nil {
        let detail = msg.isEmpty ? "Expected non-nil" : msg
        throw AssertionError(message: detail)
    }
}

func assertGreaterThan<T: Comparable>(_ a: T, _ b: T, _ msg: String = "") throws {
    if a <= b {
        let detail = msg.isEmpty ? "Expected \(a) > \(b)" : msg
        throw AssertionError(message: detail)
    }
}

func assertNotEqual<T: Equatable>(_ a: T, _ b: T, _ msg: String = "") throws {
    if a == b {
        let detail = msg.isEmpty ? "Expected values to differ" : msg
        throw AssertionError(message: detail)
    }
}

func printResults() {
    print(String(repeating: "=", count: 60))
    if totalFailed == 0 {
        print("  ✅ All \(totalTests) tests passed!")
    } else {
        print("  ❌ \(totalPassed)/\(totalTests) passed, \(totalFailed) failed")
        print()
        for name in failedTests {
            print("  FAILED: \(name)")
        }
    }
    print(String(repeating: "=", count: 60))
}
