# TCASwitchCaseView

TCASwitchCaseView package includes WithSwitchCaseView, a Swift macro that generates a View declaration associated with a TCA enum Reducer.

* [Why use WithSwitchCaseView?](#why-use-withswitchcaseview)
* [Usage](#usage)
* [Installation](#installation)

## Why use WithSwitchCaseView?

It’s common to have a parent feature that switches between child reducers.
Without any macro help, you end up writing repetitive "switching" views like this:

```swift
import SwiftUI
import ComposableArchitecture

@Reducer
enum Home {
    case details(Details)
    case settings(Settings)
}

struct HomeView: View {
    let store: StoreOf<Home>

    var body: some View {
        switch store.state {
        case .details:
            if let store = store.scope(state: \.details, action: \.details) {
                Detail.DetailsView(store: store)
            }
        case .settings:
            if let store = store.scope(state: \.settings, action: \.settings) {
                Settings.SettingsView(store: store)
            }
        }
    }
}
```
Even for a small feature, you can see the pattern:
- you must **manually scope** the store for every enum case
- you must **repeat the view name and match the case names**
- this must be done **every time a new case is added or removed**

Using `@WithSwitchCaseView` you can express the same behavior declaratively, with just one line of code:
```swift
import SwiftUI
import ComposableArchitecture
import WithSwitchCaseView

@WithSwitchCaseView
@Reducer(state: .equatable)
enum Home {
    case details(Details)
    case settings(Settings)
}
```

The macro then automatically generates:
```swift
extension Home {
    public struct HomeView: SwiftUI.View {
        let store: Store<State, Action>

        public var body: some SwiftUI.View {
            switch store.state {
            case .details:
                if let store = store.scope(state: \.details, action: \.details) {
                    Details.DetailsView(store: store)
                }
            case .settings:
                if let store = store.scope(state: \.settings, action: \.settings) {
                    Settings.SettingsView(store: store)
                }
            }
        }
    }
}
```
### Benefits ✅ 
There are several immediate **benefits** to this approach:
- **Removes boilerplate** - no more manually writing repetitive code.
- **Enforces consistent naming** - requires the view names to follow a simple naming convention.
- **Cleaner diffs for future features** - adding a new feature now just means adding a new case, doing away with boilerplate code which just adds development overhead and makes relevant changes less clear.
- **Centralized updates** - an update to TCA that affects these views can just be updated in this macro and applied wherever the macro is used.

## Usage
> [!NOTE]
> The `WithSwitchCaseView` macro assumes that you structure your TCA features such that views associated with a Reducer are nested within the reducer itself, with a "View" suffix:
> ```swift
> import SwiftUI
> import ComposableArchitecture
> 
> @Reducer
> struct Feature {
>     // The declaration of the feature's view is nested within the reducer body or extension.
>     // The name of the view is the name of the feature with the "View" suffix appended.
>     struct FeatureView: View {
>     ...
>     }
> }
> ```

To use the macro, simply apply `@WithSwitchCaseView` alongside `@Reducer` to the desired type:
```swift
import SwiftUI
import ComposableArchitecture
import TCASwitchCaseView

@WithSwitchCaseView
@Reducer(state: .equatable)
enum Home {
    case details(Details)
    case settings(Settings)
}
```

## Installation
Add the following to your Package.swift file:
```swift
.package("...")
```
