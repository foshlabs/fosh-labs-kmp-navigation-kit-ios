import SwiftUI

/// Protocol that consuming projects implement to provide views for each scene.
///
/// Example:
/// ```swift
/// struct AppSceneFactory: SceneViewFactory {
///     @ViewBuilder
///     func view(for scene: AppScene) -> some View {
///         switch scene {
///         case .home: HomeView()
///         case .settings: SettingsView()
///         }
///     }
/// }
/// ```
public protocol SceneViewFactory {
    associatedtype SceneType: Hashable & Identifiable
    associatedtype SceneView: View

    @ViewBuilder
    func view(for scene: SceneType) -> SceneView
}
