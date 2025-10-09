/// Generates a SwiftUI `View` for a TCA enum Reducer using vanilla `switch` and `case` syntax.
/// The generated view is declared in an extension on the type to which it is applied.
///
/// Child features must define a view named after the reducer type with a `View` suffix:
/// ```swift
/// @Reducer
/// struct Details {
///   struct DetailsView: View { ... }
/// }
/// ```
///
/// Apply `@WithSwitchCaseView` alongside `@Reducer` on your enum reducer:
/// ```swift
/// @WithSwitchCaseView
/// @Reducer(state: .equatable)
/// enum Home {
///   case details(Details)
///   case settings(Settings)
/// }
/// ```
///
/// The macro in the example above expands to a `Home.HomeView` that displays the appropriate child view for each case, scoped via its reducer.
/// ```swift
/// extension Home {
///     public struct HomeView: SwiftUI.View {
///         let store: Store<State, Action>
///         public var body: some SwiftUI.View {
///             switch store.state {
///             case .details:
///                 if let store = store.scope(state: \.details, action: \.details) {
///                     Details.DetailsView(store: store)
///                 }
///             case .settings:
///                 if let store = store.scope(state: \.settings, action: \.settings) {
///                     Settings.SettingsView(store: store)
///                 }
///             }
///         }
///     }
/// }
/// ```
@attached(extension, names: named(View))
public macro WithSwitchCaseView() = #externalMacro(module: "EnumReducerViewMacros", type: "WithSwitchCaseViewMacro")
