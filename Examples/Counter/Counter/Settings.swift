import SwiftUI
import ComposableArchitecture

@Reducer
struct Settings {
    @ObservableState
    struct State {
        var selectedColor: ColorOption = .blue
        let colorOptions: [ColorOption] = ColorOption.allCases
    }
    enum Action: BindableAction {
        case setTintColor(ColorOption)
        case binding(BindingAction<State>)
    }
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.selectedColor):
                return .send(.setTintColor(state.selectedColor))
            default:
                return .none
            }
        }
    }
}

extension Settings {
    struct SettingsView: View {
        @Bindable var store: Store<State, Action>
        var body: some View {
            VStack {
                Text("Select Tint Color")
                    .font(.headline)

                Picker("", selection: $store.selectedColor) {
                    ForEach(store.colorOptions) { color in
                        Text(color.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }
            .tint(store.selectedColor.color)
        }
    }
}
