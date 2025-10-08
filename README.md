# EnumReducerView

EnumReducerView is a Swift macro that generates a View declaration associated with a TCA enum Reducer.

## Usage
The `EnumReducerView` macro assumes that you structure your features such that each child feature defines a nested View type named after the reducer, with a "View" suffix:
```swift
import SwiftUI
import ComposableArchitecture

@Reducer
struct Feature {
    // The declaration of the feature's view is nested within the reducer body or extension.
    // The name of the view is the name of the feature with the "View" suffix appended.
    struct FeatureView: View {
    ...
    }
}
```

To use the macro, apply `@EnumReducerView` alongside `@Reducer` to the desired type:
```swift
import SwiftUI
import ComposableArchitecture
import EnumReducerView

@EnumReducerView
@Reducer(state: .equatable)
enum Home {
    case details(Details)
    case settings(Settings)
}
```
### Generated code
The expansion in the example above results in the following code:
```swift
import SwiftUI
import ComposableArchitecture
import EnumReducerView

@Reducer(state: .equatable)
enum Home {
    case details(Details)
    case settings(Settings)
}
extension Home {
    public struct View: SwiftUI.View {
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
