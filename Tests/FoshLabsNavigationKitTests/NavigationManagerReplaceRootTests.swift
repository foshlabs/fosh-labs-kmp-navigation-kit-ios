import XCTest
@testable import FoshLabsNavigationKit

final class NavigationManagerReplaceRootTests: XCTestCase {

    private enum Scene: Hashable, Identifiable {
        case onboarding, permission, home, detail
        var id: Self { self }
    }

    private func makeNavigator() -> NavigationManager<Scene> {
        let navigator = NavigationManager(initialScene: Scene.onboarding)
        navigator.process(action: .push(.permission))
        return navigator
    }

    func testReplaceRootRetiresOutgoingPathAndClearsCurrentPath() {
        let navigator = makeNavigator()

        navigator.process(action: .replaceRoot(.home))

        XCTAssertEqual(navigator.rootScene, .home)
        XCTAssertEqual(navigator.path.count, 0)
        XCTAssertEqual(navigator.retiredPath(for: .onboarding).count, 1)
        XCTAssertEqual(navigator.retiredPath(for: .home).count, 0)
    }

    func testPushImmediatelyAfterReplaceRootLandsOnNewRoot() {
        let navigator = makeNavigator()

        navigator.process(action: .replaceRoot(.home))
        navigator.process(action: .push(.detail))

        XCTAssertEqual(navigator.path.count, 1)
        XCTAssertEqual(navigator.retiredPath(for: .onboarding).count, 1)
    }

    func testReplaceRootWithSameRootOnlyClearsPath() {
        let navigator = makeNavigator()

        navigator.process(action: .replaceRoot(.onboarding))

        XCTAssertEqual(navigator.rootScene, .onboarding)
        XCTAssertEqual(navigator.path.count, 0)
        XCTAssertTrue(navigator.retiredPaths.isEmpty)
    }

    func testSecondReplaceRootDuringFadeKeepsFirstRetiredPath() {
        let navigator = makeNavigator()

        navigator.process(action: .replaceRoot(.home))
        navigator.process(action: .push(.detail))
        navigator.process(action: .replaceRoot(.detail))

        XCTAssertEqual(navigator.rootScene, .detail)
        XCTAssertEqual(navigator.path.count, 0)
        XCTAssertEqual(navigator.retiredPath(for: .onboarding).count, 1)
        XCTAssertEqual(navigator.retiredPath(for: .home).count, 1)
    }

    func testReplaceRootDismissesModals() {
        let navigator = makeNavigator()
        navigator.process(action: .presentSheet(.detail))
        navigator.process(action: .presentFullScreen(.detail))

        navigator.process(action: .replaceRoot(.home))

        XCTAssertNil(navigator.sheet)
        XCTAssertNil(navigator.fullScreenCover)
    }

    func testReleaseRetiredPathOnlyForMatchingRoot() {
        let navigator = makeNavigator()
        navigator.process(action: .replaceRoot(.home))

        navigator.releaseRetiredPath(for: .home)
        XCTAssertEqual(navigator.retiredPaths.count, 1)

        navigator.releaseRetiredPath(for: .onboarding)
        XCTAssertTrue(navigator.retiredPaths.isEmpty)
        XCTAssertEqual(navigator.retiredPath(for: .onboarding).count, 0)
    }
}
