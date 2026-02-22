import Foundation

/// Swift-native mirror of the KMP NavigationState sealed interface.
/// Consuming projects bridge from their KMP NavigationState to this enum.
public enum NavigationAction<SceneType: Hashable> {
    case none
    case replaceRoot(SceneType)
    case presentSheet(SceneType)
    case presentFullScreen(SceneType)
    case dismiss
    case push(SceneType)
    case pop
    case popToRoot
    case popTo(SceneType?, inclusive: Bool)
}
