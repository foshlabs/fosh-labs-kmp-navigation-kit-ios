import SwiftUI

/// Main navigation host that provides NavigationStack with sheet and fullScreenCover support.
/// Generic over `SceneType` and uses a `SceneViewFactory` to create views.
public struct NavigationHost<SceneType: Hashable & Identifiable, Factory: SceneViewFactory>: View
    where Factory.SceneType == SceneType {

    // MARK: - Properties

    @ObservedObject private var navigator: NavigationManager<SceneType>
    private let factory: Factory

    // MARK: - Initialization

    public init(navigator: NavigationManager<SceneType>, factory: Factory) {
        self._navigator = ObservedObject(wrappedValue: navigator)
        self.factory = factory
    }

    // MARK: - Layout

    public var body: some View {
        NavigationStack(path: $navigator.path) {
            factory.view(for: navigator.rootScene)
                .navigationDestination(for: SceneType.self) { scene in
                    factory.view(for: scene)
                }
        }
        .sheet(item: $navigator.sheet) { scene in
            factory.view(for: scene)
        }
        .fullScreenCover(item: $navigator.fullScreenCover) { scene in
            ModalNavigationHost(rootScene: scene, factory: factory)
        }
        .animation(.easeInOut(duration: 0.3), value: navigator.rootScene)
    }
}

/// Navigation host for modal contexts (fullScreenCover).
/// Gets its own ModalNavigationManager for independent push/pop within the modal.
public struct ModalNavigationHost<SceneType: Hashable & Identifiable, Factory: SceneViewFactory>: View
    where Factory.SceneType == SceneType {

    // MARK: - Properties

    @StateObject private var modalNavigator = ModalNavigationManager()
    let rootScene: SceneType
    let factory: Factory

    // MARK: - Initialization

    public init(rootScene: SceneType, factory: Factory) {
        self.rootScene = rootScene
        self.factory = factory
    }

    // MARK: - Layout

    public var body: some View {
        NavigationStack(path: $modalNavigator.path) {
            factory.view(for: rootScene)
                .navigationDestination(for: SceneType.self) { scene in
                    factory.view(for: scene)
                }
        }
        .sheet(item: sheetBinding) { scene in
            factory.view(for: scene)
        }
        .environmentObject(modalNavigator)
        .environment(\.modalNavigationManager, modalNavigator)
    }

    private var sheetBinding: Binding<SceneType?> {
        Binding(
            get: { modalNavigator.currentSheet(as: SceneType.self) },
            set: { newValue in
                if let scene = newValue {
                    modalNavigator.presentSheet(scene)
                } else {
                    modalNavigator.dismissSheet()
                }
            }
        )
    }
}
