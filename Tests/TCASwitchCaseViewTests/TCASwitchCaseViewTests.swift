import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftDiagnostics
import XCTest

#if canImport(TCASwitchCaseViewMacros)
import TCASwitchCaseViewMacros
import ComposableArchitecture

let testMacros: [String: Macro.Type] = [
    "WithSwitchCaseView": WithSwitchCaseViewMacro.self,
]
#endif

final class TCASwitchCaseViewTests: XCTestCase {
    func testMacroOnEmptyEnum() throws {
        #if canImport(TCASwitchCaseViewMacros)
        assertMacroExpansion(
            """
            @WithSwitchCaseView
            @Reducer
            enum Home {}
            """,
            expandedSource: """
            @Reducer
            enum Home {}
            
            extension Home {
                public struct HomeView: SwiftUI.View {
                    let store: Store<State, Action>
                    public var body: some SwiftUI.View {
                        EmptyView()
                    }
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Enum has no cases, emitting an EmptyView() in the View body",
                    line: 3,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroOnEnumReducerWithOneCase() throws {
        #if canImport(TCASwitchCaseViewMacros)
        assertMacroExpansion(
            """
            import SwiftUI
            import ComposableArchitecture

            @Reducer
            struct Details {}

            @WithSwitchCaseView
            @Reducer
            enum Home {
                case details(Details)
            }
            """,
            expandedSource: """
            import SwiftUI
            import ComposableArchitecture

            @Reducer
            struct Details {}
            @Reducer
            enum Home {
                case details(Details)
            }

            extension Home {
                public struct HomeView: SwiftUI.View {
                    let store: Store<State, Action>
                    public var body: some SwiftUI.View {
                        switch store.state {
                        case .details:
                            if let store = store.scope(state: \\.details, action: \\.details) {
                                Details.DetailsView(store: store)
                            }
                        }
                    }
                }
            }

            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroOnEnumReducerWithTwoCases() throws {
        #if canImport(TCASwitchCaseViewMacros)
        assertMacroExpansion(
            """
            import SwiftUI
            import ComposableArchitecture
            
            @Reducer
            struct Details {}
            
            @Reducer
            struct Settings {}
            
            @WithSwitchCaseView
            @Reducer
            enum Home {
                case details(Details)
                case settings(Settings)
            }
            """,
            expandedSource: """
            import SwiftUI
            import ComposableArchitecture
            
            @Reducer
            struct Details {}
            
            @Reducer
            struct Settings {}
            @Reducer
            enum Home {
                case details(Details)
                case settings(Settings)
            }
            
            extension Home {
                public struct HomeView: SwiftUI.View {
                    let store: Store<State, Action>
                    public var body: some SwiftUI.View {
                        switch store.state {
                        case .details:
                            if let store = store.scope(state: \\.details, action: \\.details) {
                                Details.DetailsView(store: store)
                            }
                        case .settings:
                            if let store = store.scope(state: \\.settings, action: \\.settings) {
                                Settings.SettingsView(store: store)
                            }
                        }
                    }
                }
            }

            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroOnNestedEnumReducerWithTwoCases() throws {
        #if canImport(TCASwitchCaseViewMacros)
        assertMacroExpansion(
            """
            import SwiftUI
            import ComposableArchitecture

            @Reducer
            struct Details {}
            
            @Reducer
            struct Settings {}
            
            @Reducer
            struct Home {}

            extension Home {
                @WithSwitchCaseView
                @Reducer
                enum Sheet {
                    case details(Details)
                    case settings(Settings)
                }
            }
            """,
            expandedSource: """
            import SwiftUI
            import ComposableArchitecture

            @Reducer
            struct Details {}
            
            @Reducer
            struct Settings {}
            
            @Reducer
            struct Home {}

            extension Home {
                @Reducer
                enum Sheet {
                    case details(Details)
                    case settings(Settings)
                }
            }

            extension Home.Sheet {
                public struct SheetView: SwiftUI.View {
                    let store: Store<State, Action>
                    public var body: some SwiftUI.View {
                        switch store.state {
                        case .details:
                            if let store = store.scope(state: \\.details, action: \\.details) {
                                Details.DetailsView(store: store)
                            }
                        case .settings:
                            if let store = store.scope(state: \\.settings, action: \\.settings) {
                                Settings.SettingsView(store: store)
                            }
                        }
                    }
                }
            }

            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

}
