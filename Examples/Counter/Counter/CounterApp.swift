import SwiftUI
import ComposableArchitecture

@main
struct CounterApp: App {
    var body: some Scene {
        WindowGroup {
            Counter.CounterView(store: Store(initialState: .init(), reducer: { Counter() }))
        }
    }
}
