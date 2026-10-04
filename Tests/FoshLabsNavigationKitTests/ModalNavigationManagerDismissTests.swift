import XCTest
@testable import FoshLabsNavigationKit

final class ModalNavigationManagerDismissTests: XCTestCase {

    private enum Scene: Hashable {
        case form, contacts, newContact
    }

    func testDismissClosesOwnSheetFirst() {
        let parent = ModalNavigationManager()
        let modal = ModalNavigationManager(parent: parent)
        parent.presentSheet(Scene.contacts)
        modal.presentSheet(Scene.newContact)

        XCTAssertTrue(modal.dismiss())

        XCTAssertNil(modal.sheet)
        XCTAssertEqual(parent.currentSheet(as: Scene.self), .contacts)
    }

    func testDismissInNestedSheetClosesTheSheetItIsShownIn() {
        let parent = ModalNavigationManager()
        parent.push(Scene.contacts)
        parent.presentSheet(Scene.newContact)
        let nested = ModalNavigationManager(parent: parent)

        XCTAssertTrue(nested.dismiss())

        XCTAssertNil(parent.sheet)
        XCTAssertEqual(parent.path.count, 1)
    }

    func testDismissInFirstLevelSheetLeavesItToTheRootNavigator() {
        let modal = ModalNavigationManager()

        XCTAssertFalse(modal.dismiss())
    }

    func testNestedManagerKeepsItsOwnStack() {
        let parent = ModalNavigationManager()
        let nested = ModalNavigationManager(parent: parent)

        nested.push(Scene.form)

        XCTAssertEqual(nested.path.count, 1)
        XCTAssertEqual(parent.path.count, 0)
    }
}
