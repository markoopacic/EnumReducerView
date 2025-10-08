/// Generates a SwiftUI `View` nested in an extension on the type to which it is applied.
/// The generated `View` is declared in an extension on the type to which it is applied.
/// Can only be applied to enum Reducer types.
///
/// Child features must define a view named after the reducer type with a `View` suffix:
/// ```swift
/// @Reducer
/// struct Details {
///   struct DetailsView: View { ... }
/// }
/// ```
///
/// Apply `@EnumReducerView` alongside `@Reducer` on your enum reducer:
/// ```swift
/// @EnumReducerView
/// @Reducer(state: .equatable)
/// enum Home {
///   case details(Details)
///   case settings(Settings)
/// }
/// ```
///
/// The macro expands to a `Home.View` that displays the appropriate child view for each case, scoped via its reducer.
@attached(extension, names: named(View))
public macro EnumReducerView() = #externalMacro(module: "EnumReducerViewMacros", type: "EnumReducerViewMacro")
