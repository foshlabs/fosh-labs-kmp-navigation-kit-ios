import Combine
import SwiftUI

/// View modifier that observes a navigation action publisher and processes navigation events.
///
/// Usage in consuming project:
/// ```swift
/// .handleNavigation(viewModel) { navigationState in
///     navigationState.mapToAction() // Convert KMP NavigationState to NavigationAction
/// }
/// ```
private struct NavigationHandlerModifier<SceneType: Hashable & Identifiable>: ViewModifier {
    let publisher: AnyPublisher<Any, Error>
    let mapper: (Any) -> NavigationAction<SceneType>
    let onConsumed: () -> Void

    @EnvironmentObject private var navigator: NavigationManager<SceneType>
    @Environment(\.modalNavigationManager) private var modalNavigator
    @State private var cancellable: AnyCancellable? = nil

    func body(content: Content) -> some View {
        content
            .onAppear {
                cancellable = publisher
                    .receive(on: RunLoop.main)
                    .sink(
                        receiveCompletion: { completion in
                            switch completion {
                            case let .failure(error):
                                print("🚦 NavigationState flow publisher failed: \(error)")
                            case .finished:
                                print("🚦 NavigationState flow publisher finished")
                            }
                        },
                        receiveValue: { value in
                            let action = mapper(value)
                            guard case .none = action else {
                                processNavigation(action: action)
                                onConsumed()
                                return
                            }
                        }
                    )
            }
            .onDisappear {
                cancellable?.cancel()
                cancellable = nil
            }
    }

    private func processNavigation(action: NavigationAction<SceneType>) {
        if let modalNav = modalNavigator {
            switch action {
            case let .push(destination):
                modalNav.push(destination)
                return

            case .pop:
                modalNav.pop()
                return

            case .popToRoot:
                modalNav.popToRoot()
                return

            case let .presentSheet(destination):
                modalNav.presentSheet(destination)
                return

            case .dismiss:
                if modalNav.sheet != nil {
                    modalNav.dismissSheet()
                } else {
                    navigator.process(action: action)
                }
                return

            default:
                break
            }
        }

        navigator.process(action: action)
    }
}

public extension View {

    /// Attaches navigation handling to a view.
    ///
    /// - Parameters:
    ///   - publisher: A Combine publisher that emits navigation state values (typically from KMP ViewModel)
    ///   - mapper: Converts the raw navigation state value to a typed `NavigationAction`
    ///   - onConsumed: Called after processing a navigation event (typically calls `viewModel.consumeNavigation()`)
    func handleNavigation<SceneType: Hashable & Identifiable>(
        publisher: AnyPublisher<Any, Error>,
        mapper: @escaping (Any) -> NavigationAction<SceneType>,
        onConsumed: @escaping () -> Void
    ) -> some View {
        modifier(NavigationHandlerModifier(
            publisher: publisher,
            mapper: mapper,
            onConsumed: onConsumed
        ))
    }
}
