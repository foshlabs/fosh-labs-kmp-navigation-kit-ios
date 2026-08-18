import SwiftUI

/// Manages global navigation state for the app.
/// Generic over `SceneType` so it works with any project's scene definition.
public class NavigationManager<SceneType: Hashable & Identifiable>: ObservableObject {

    // MARK: - Properties

    @Published public var path = NavigationPath()
    @Published public var sheet: SceneType?
    @Published public var fullScreenCover: SceneType?
    @Published public var rootScene: SceneType

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
            // A presented modal is not part of `path` — without this it would
            // keep covering the freshly replaced root.
            sheet = nil
            fullScreenCover = nil
            rootScene = destination
            path = NavigationPath()

        default:
            break
        }
    }
}
