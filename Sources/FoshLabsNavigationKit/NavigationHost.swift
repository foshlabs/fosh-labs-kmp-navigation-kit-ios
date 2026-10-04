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
        RootNavigationStack(root: navigator.rootScene, navigator: navigator, factory: factory)
            .id(navigator.rootScene)
            .transition(.opacity)
            .sheet(item: $navigator.sheet) { scene in
                ModalNavigationHost(rootScene: scene, factory: factory)
            }
            .fullScreenCover(item: $navigator.fullScreenCover) { scene in
                ModalNavigationHost(rootScene: scene, factory: factory)
            }
    }
}

/// One NavigationStack per root scene. Replacing the root swaps the whole stack with a
/// cross-fade. The incoming stack owns `navigator.path` from its first frame; the outgoing
/// one renders the path it was retired with (see `NavigationManager.retiredPaths`), so it
/// fades out showing the screen the user was on instead of popping to its root.
private struct RootNavigationStack<SceneType: Hashable & Identifiable, Factory: SceneViewFactory>: View
    where Factory.SceneType == SceneType {

    let root: SceneType
    @ObservedObject var navigator: NavigationManager<SceneType>
    let factory: Factory

    var body: some View {
        NavigationStack(path: path) {
            factory.view(for: root)
                .navigationDestination(for: SceneType.self) { scene in
                    factory.view(for: scene)
                }
        }
        .onDisappear {
            navigator.releaseRetiredPath(for: root)
        }
    }

    private var path: Binding<NavigationPath> {
        if root == navigator.rootScene {
            return $navigator.path
        }
        return .constant(navigator.retiredPath(for: root))
    }
}

/// Navigation host for modal contexts (sheet and fullScreenCover).
/// Gets its own ModalNavigationManager for independent push/pop within the modal.
public struct ModalNavigationHost<SceneType: Hashable & Identifiable, Factory: SceneViewFactory>: View
    where Factory.SceneType == SceneType {

    // MARK: - Properties

    @StateObject private var modalNavigator: ModalNavigationManager
    let rootScene: SceneType
    let factory: Factory

    // MARK: - Initialization

    public init(rootScene: SceneType, factory: Factory) {
        self.init(rootScene: rootScene, factory: factory, parent: nil)
    }

    init(rootScene: SceneType, factory: Factory, parent: ModalNavigationManager?) {
        self._modalNavigator = StateObject(wrappedValue: ModalNavigationManager(parent: parent))
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
            ModalNavigationHost(rootScene: scene, factory: factory, parent: modalNavigator)
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
