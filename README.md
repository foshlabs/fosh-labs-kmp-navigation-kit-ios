# Fosh Labs KMP Navigation Kit — iOS

SwiftUI navigation components for use with [fosh-labs-kmp-navigation-kit](https://github.com/foshlabs/fosh-labs-kmp-navigation-kit).

This package provides the iOS-side navigation infrastructure that pairs with the KMP shared navigation architecture. It has **zero dependency** on any KMP framework — the consuming project bridges between KMP types and this package's Swift-native types.

## Installation

Add via Swift Package Manager:

```
https://github.com/foshlabs/fosh-labs-kmp-navigation-kit-ios
```

## Components

- **`NavigationAction`** — Swift enum mirroring KMP `NavigationState`
- **`NavigationManager`** — Generic ObservableObject managing NavigationPath, sheets, and fullScreenCover
- **`NavigationHost`** — Root NavigationStack with modal support
- **`ModalNavigationManager`** — Independent navigation stack for modal contexts
- **`NavigationHandlerModifier`** — View modifier that observes and processes navigation events
- **`SceneViewFactory`** — Protocol for mapping scenes to SwiftUI views

## Usage

### 1. Define your scene enum

```swift
enum AppScene: Hashable, Identifiable {
    case home, settings, onboarding
    var id: Self { self }
}
```

### 2. Implement SceneViewFactory

```swift
struct AppSceneFactory: SceneViewFactory {
    @ViewBuilder
    func view(for scene: AppScene) -> some View {
        switch scene {
        case .home: HomeView()
        case .settings: SettingsView()
        case .onboarding: OnboardingView()
        }
    }
}
```

### 3. Set up NavigationHost

```swift
@main
struct MyApp: App {
    @StateObject private var navigator = NavigationManager(initialScene: AppScene.home)

    var body: some Scene {
        WindowGroup {
            NavigationHost(navigator: navigator, factory: AppSceneFactory())
                .environmentObject(navigator)
        }
    }
}
```

### 4. Bridge KMP NavigationState to NavigationAction

```swift
import Shared

extension Shared.NavigationState {
    func mapToAction() -> NavigationAction<AppScene> {
        switch self {
        case is NavigationStateNone: return .none
        case let s as NavigationStatePush: return .push(s.destination.mapScene())
        case let s as NavigationStatePresentSheet: return .presentSheet(s.destination.mapScene())
        case is NavigationStateDismiss: return .dismiss
        // ... etc
        default: return .none
        }
    }
}
```

### 5. Handle navigation in views

```swift
SomeView()
    .handleNavigation(
        publisher: createPublisher(for: viewModel.navigationStatesFlow),
        mapper: { ($0 as! NavigationState).mapToAction() },
        onConsumed: { viewModel.consumeNavigation() }
    )
```
