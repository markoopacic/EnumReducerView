import SwiftUI
import ComposableArchitecture
import TCASwitchCaseView

@Reducer
struct Counter {
    @ObservableState
    struct State {
        var number: Int = 0
        var tintColor: ColorOption = .blue
        @Presents var sheet: Sheet.State?
    }

    enum Action {
        case plusTap
        case minusTap
        case infoTap
        case settingsTap

        case sheet(PresentationAction<Sheet.Action>)
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .plusTap:
                state.number += 1
            case .minusTap:
                state.number -= 1
            case .infoTap:
                state.sheet = .info(.init(number: state.number))
            case .settingsTap:
                state.sheet = .settings(.init())
            case .sheet(.presented(.settings(.setTintColor(let color)))):
                state.tintColor = color
            case .sheet:
                break
            }
            return .none
        }
        .ifLet(\.$sheet, action: \.sheet)
    }
}

// MARK: - CounterView

extension Counter {
    struct CounterView: View {
        @Bindable var store: Store<State, Action>
        var body: some View {
            VStack(spacing: 16) {
                HStack {
                    Button("-") {
                        store.send(.minusTap)
                    }
                    .disabled(store.number <= 0)

                    Text("\(store.number)")

                    Button("+") {
                        store.send(.plusTap)
                    }
                }
                .buttonStyle(.bordered)

                Button("Info") {
                    store.send(.infoTap)
                }
                .buttonStyle(.borderedProminent)

                Button("Settings") {
                    store.send(.settingsTap)
                }
            }
            .tint(store.tintColor.color)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .sheet(item: $store.scope(state: \.sheet, action: \.sheet)) { store in
                Sheet.SheetView(store: store)
            }
        }
    }
}

// MARK: - Sheet

extension Counter {
    @WithSwitchCaseView
    @Reducer
    enum Sheet {
        case info(Info)
        case settings(Settings)
    }
}

// MARK: - Preview

#Preview {
    Counter.CounterView(store: Store(initialState: .init()) {
        Counter()
    })
}
