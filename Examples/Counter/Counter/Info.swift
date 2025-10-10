import SwiftUI
import ComposableArchitecture

@Reducer
struct Info {
    @ObservableState
    struct State {
        let number: Int
    }
}

extension Info {
    struct InfoView: View {
        let store: Store<State, Action>
        var body: some View {
            Text("\(store.number) is \(store.number.isMultiple(of: 2) ? "even" : "odd")")
        }
    }
}
