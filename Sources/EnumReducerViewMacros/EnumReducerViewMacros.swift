import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

@main
struct EnumReducerViewPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        WithSwitchCaseViewMacro.self
    ]
}

public struct WithSwitchCaseViewMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard
            let enumDecl = declaration.as(EnumDeclSyntax.self)
        else {
            context.diagnose(
                Diagnostic(
                    node: declaration,
                    message: MacroExpansionErrorMessage("WithSwitchCaseView can only be applied to enum types")
                )
            )

            return []
        }

        let caseDecls = enumDecl.memberBlock.members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let caseElements = caseDecls.flatMap { $0.elements }

        var bodyContent: CodeBlockItemSyntax.Item
        if caseElements.isEmpty {
            context.diagnose(
                Diagnostic(
                    node: Syntax(enumDecl.enumKeyword),
                    message: MacroExpansionWarningMessage("Enum has no cases, emitting an EmptyView() in the View body")
                )
            )

            bodyContent = .expr(ExprSyntax(FunctionCallExprSyntax(callee: ExprSyntax("EmptyView"))))
        } else {
            let switchExpr = makeSwitchExpr(for: caseElements)

            bodyContent = .expr(ExprSyntax(switchExpr))
        }

        let bodyDecl = VariableDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.public))
            },
            .var,
            name: PatternSyntax(stringLiteral: "body"),
            type: TypeAnnotationSyntax(type: TypeSyntax(stringLiteral: "some SwiftUI.View")),
            accessorBlock: AccessorBlockSyntax(
                accessors: .getter(CodeBlockItemListSyntax {
                    CodeBlockItemSyntax(item: bodyContent)
                })
            )
        )

        let baseTypeName = String(type.trimmedDescription.split(separator: ".").last ?? "")
        let viewName = baseTypeName + "View"

        let viewStructDecl = StructDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.public))
            },
            name: TokenSyntax(stringLiteral: viewName),
            inheritanceClause: InheritanceClauseSyntax(
                inheritedTypes: InheritedTypeListSyntax {
                    InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "SwiftUI.View"))
                }
            )
        ) {
            DeclSyntax("let store: Store<State, Action>")
            DeclSyntax(bodyDecl)
        }

        let extensionDecl = ExtensionDeclSyntax(extendedType: type) {
            DeclSyntax(viewStructDecl)
        }

        return [extensionDecl]
    }

    private static func makeSwitchExpr(for elements: [EnumCaseElementSyntax]) -> SwitchExprSyntax {
        let cases: [SwitchCaseSyntax] = elements.map { element in
            let caseName = element.name.text

            let caseLabel = SwitchCaseLabelSyntax(
                leadingTrivia: .newline,
                caseKeyword: .keyword(.case, trailingTrivia: .space),
                caseItems: SwitchCaseItemListSyntax {
                    SwitchCaseItemSyntax(
                        pattern: ExpressionPatternSyntax(
                            expression: MemberAccessExprSyntax(
                                base: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(""))),
                                name: .identifier(caseName)
                            )
                        ),
                    )
                },
                colon: .colonToken()
            )

            if let feature = element.parameterClause?.parameters.first?.type.as(IdentifierTypeSyntax.self) {
                let featureName = feature.name.text
                let featureViewExpr = FunctionCallExprSyntax(
                    callee: ExprSyntax(
                        MemberAccessExprSyntax(
                            base: ExprSyntax(stringLiteral: featureName),
                            name: .identifier("\(featureName)View")))
                ) {
                    LabeledExprListSyntax {
                        LabeledExprSyntax(
                            label: .identifier("store"),
                            colon: .colonToken(trailingTrivia: .space),
                            expression: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier("store")))
                        )
                    }
                }

                let storeScopeElement = ConditionElementListSyntax {
                    OptionalBindingConditionSyntax(
                        bindingSpecifier: .keyword(.let),
                        pattern: PatternSyntax(
                            IdentifierPatternSyntax(identifier: .identifier("store"))
                        ),
                        initializer: InitializerClauseSyntax(
                            equal: .equalToken(trailingTrivia: .space),
                            value: ExprSyntax(
                                FunctionCallExprSyntax(
                                    callee: ExprSyntax(MemberAccessExprSyntax(
                                        base: ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier("store"))),
                                        name: .identifier("scope")))
                                ) {
                                    LabeledExprListSyntax {
                                        LabeledExprSyntax(
                                            label: .identifier("state"),
                                            colon: .colonToken(trailingTrivia: .space),
                                            expression: ExprSyntax(
                                                KeyPathExprSyntax(
                                                    backslash: .backslashToken(),
                                                    components: KeyPathComponentListSyntax {
                                                        KeyPathComponentSyntax(
                                                            period: .periodToken(),
                                                            component: .property(
                                                                KeyPathPropertyComponentSyntax(
                                                                    declName: DeclReferenceExprSyntax(
                                                                        baseName: .identifier(caseName)))))
                                                    }
                                                )
                                            )
                                        )
                                        LabeledExprSyntax(
                                            label: .identifier("action"),
                                            colon: .colonToken(trailingTrivia: .space),
                                            expression: ExprSyntax(
                                                KeyPathExprSyntax(
                                                    backslash: .backslashToken(),
                                                    components: KeyPathComponentListSyntax {
                                                        KeyPathComponentSyntax(
                                                            period: .periodToken(),
                                                            component: .property(
                                                                KeyPathPropertyComponentSyntax(
                                                                    declName: DeclReferenceExprSyntax(
                                                                        baseName: .identifier(caseName)))))
                                                    }
                                                )
                                            )
                                        )
                                    }
                                }
                            )
                        ))
                }

                let ifLetExpr = IfExprSyntax(
                    ifKeyword: .keyword(.if, trailingTrivia: .space),
                    conditions: storeScopeElement,
                    body: CodeBlockSyntax {
                        CodeBlockItemListSyntax {
                            CodeBlockItemSyntax(item: .expr(ExprSyntax(
                                featureViewExpr
                            )))
                        }
                    }
                )

                let statements = CodeBlockItemListSyntax {
                    ifLetExpr
                }

                return SwitchCaseSyntax(
                    label: SwitchCaseSyntax.Label(caseLabel),
                    statements: statements
                )
            }

            let statements = CodeBlockItemListSyntax {
                CodeBlockItemSyntax(item: .expr(ExprSyntax(
                    FunctionCallExprSyntax(
                        callee: ExprSyntax("EmptyView"))
                )))
            }

            return SwitchCaseSyntax(
                label: SwitchCaseSyntax.Label(caseLabel),
                statements: statements
            )
        }

        let switchExpr = SwitchExprSyntax(
            switchKeyword: .keyword(.switch, trailingTrivia: .space),
            subject: ExprSyntax(MemberAccessExprSyntax(base: ExprSyntax("store"), name: "state"))
        ) {
            for caseSyntax in cases {
                caseSyntax
            }
        }

        return switchExpr
    }
}
