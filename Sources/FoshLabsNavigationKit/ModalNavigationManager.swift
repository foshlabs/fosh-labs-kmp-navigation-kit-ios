import SwiftUI

/// Manages navigation within a modal context (sheet or fullScreenCover).
/// Each modal gets its own navigation stack.
public class ModalNavigationManager: ObservableObject {

    // MARK: - Properties

    @Published public var path = NavigationPath()
    @Published public var sheet: AnyHashable?

    /// The manager of the modal this one is presented from, if it is a sheet over a sheet.
    public private(set) weak var parent: ModalNavigationManager?

    // MARK: - Initialization

    public init(parent: ModalNavigationManager? = nil) {
        self.parent = parent
    }

    // MARK: - Actions

    public func push<SceneType: Hashable>(_ scene: SceneType) {
        path.append(scene)
    }

    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    public func popToRoot() {
        path.removeLast(path.count)
    }

    public func presentSheet<SceneType: Hashable>(_ scene: SceneType) {
        sheet = AnyHashable(scene)
    }

    public func dismissSheet() {
        sheet = nil
    }

    /// Closes the topmost modal this manager can reach: its own sheet, or else the sheet it
    /// is itself shown in. Returns `false` when neither exists, so the root navigator owns
    /// the dismissal.
    @discardableResult
    public func dismiss() -> Bool {
        if sheet != nil {
            dismissSheet()
            return true
        }
        if let parent {
            parent.dismissSheet()
            return true
        }
        return false
    }

    /// Type-safe accessor for the current sheet scene.
    public func currentSheet<SceneType: Hashable>(as type: SceneType.Type) -> SceneType? {
        sheet?.base as? SceneType
    }
}

// MARK: - Environment Key

private struct ModalNavigationManagerKey: EnvironmentKey {
    static let defaultValue: ModalNavigationManager? = nil
}

public extension EnvironmentValues {

    var modalNavigationManager: ModalNavigationManager? {
        get { self[ModalNavigationManagerKey.self] }
        set { self[ModalNavigationManagerKey.self] = newValue }
    }
}
