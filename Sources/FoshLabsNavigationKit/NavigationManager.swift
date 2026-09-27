import SwiftUI

/// Manages global navigation state for the app.
/// Generic over `SceneType` so it works with any project's scene definition.
public class NavigationManager<SceneType: Hashable & Identifiable>: ObservableObject {

    // MARK: - Properties

    @Published public var path = NavigationPath()
    @Published public var sheet: SceneType?
    @Published public var fullScreenCover: SceneType?
    @Published public var rootScene: SceneType

    /// Paths of roots that `replaceRoot` has replaced, keyed by root. Each keeps the pushed
    /// screens the user was on so the outgoing `NavigationStack` can keep rendering them while
    /// it fades out instead of popping to its root. An entry is released once its stack has
    /// disappeared. Not published: it is only written inside the `rootScene` transaction or
    /// from `onDisappear`, and no live view depends on it.
    private(set) var retiredPaths: [SceneType: NavigationPath] = [:]

    // MARK: - Initialization

    public init(initialScene: SceneType) {
        self.rootScene = initialScene
    }

    // MARK: - Actions

    public func process(action: NavigationAction<SceneType>) {
        switch action {
        case .none:
            break

        case let .presentSheet(destination):
            sheet = destination

        case let .presentFullScreen(destination):
            fullScreenCover = destination

        case .dismiss:
            sheet = nil
            fullScreenCover = nil

        case let .push(destination):
            path.append(destination)

        case .pop where !path.isEmpty:
            path.removeLast()

        case .popToRoot:
            path.removeLast(path.count)

        case let .popTo(destination, inclusive):
            if let _ = destination {
                // PopTo specific destination would need path introspection
                // Simplified: handled by consuming project if needed
            } else if inclusive {
                path.removeLast(path.count)
            }

        case let .replaceRoot(destination):
            replaceRoot(with: destination)

        default:
            break
        }
    }

    // MARK: - Helpers

    private func replaceRoot(with destination: SceneType) {
        sheet = nil
        fullScreenCover = nil
        guard destination != rootScene else {
            path = NavigationPath()
            return
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            retiredPaths[rootScene] = path
            path = NavigationPath()
            rootScene = destination
        }
    }

    /// The path the outgoing stack for `root` should keep rendering while it fades out.
    func retiredPath(for root: SceneType) -> NavigationPath {
        retiredPaths[root] ?? NavigationPath()
    }

    /// Drops the retired path once the outgoing stack for `root` is gone.
    func releaseRetiredPath(for root: SceneType) {
        retiredPaths[root] = nil
    }
}
