import SwiftUI

enum ColorOption: String, CaseIterable, Equatable, Identifiable {
    case blue
    case red
    case green

    var id: Self { self }

    var color: Color {
        switch self {
        case .blue: .blue
        case .red: .red
        case .green: .green
        }
    }
}
