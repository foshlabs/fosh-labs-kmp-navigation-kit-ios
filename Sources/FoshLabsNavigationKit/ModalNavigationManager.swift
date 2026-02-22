import SwiftUI

/// Manages navigation within a modal context (fullScreenCover).
/// Each modal gets its own navigation stack.
public class ModalNavigationManager: ObservableObject {

    // MARK: - Properties

    @Published public var path = NavigationPath()
    @Published public var sheet: AnyHashable?

    // MARK: - Initialization

    public init() {}

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
