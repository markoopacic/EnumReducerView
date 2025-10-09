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
            enum TestFeature {}
            """,
            expandedSource: """
            @Reducer
            enum TestFeature {}
            
            extension TestFeature {
                public struct TestFeatureView: SwiftUI.View {
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
            struct DetailsFeature {}
            
            @Reducer
            struct TestFeature {}

            extension TestFeature {
                @WithSwitchCaseView
                @Reducer
                enum TestSheet {
                    case details(DetailsFeature)
                }
            }
            """,
            expandedSource: """
            import SwiftUI
            import ComposableArchitecture

            @Reducer
            struct DetailsFeature {}
            
            @Reducer
            struct TestFeature {}

            extension TestFeature {
                @Reducer
                enum TestSheet {
                    case details(DetailsFeature)
                }
            }

            extension TestFeature.TestSheet {
                public struct TestSheetView: SwiftUI.View {
                    let store: Store<State, Action>
                    public var body: some SwiftUI.View {
                        switch store.state {
                        case .details:
                            if let store = store.scope(state: \\.details, action: \\.details) {
                                DetailsFeature.DetailsFeatureView(store: store)
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
