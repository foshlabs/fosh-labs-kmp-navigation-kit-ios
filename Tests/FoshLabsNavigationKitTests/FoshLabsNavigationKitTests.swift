import XCTest
@testable import FoshLabsNavigationKit

final class FoshLabsNavigationKitTests: XCTestCase {

    func testNavigationActionNone() throws {
        let action: NavigationAction<MockScene> = .none
        if case .none = action {
            // Expected
        } else {
            XCTFail("Expected .none")
        }
    }
}

private enum MockScene: Hashable, Identifiable {
    case home
    case settings

    var id: Self { self }
}
