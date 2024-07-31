import SwiftSyntax
import SwiftSyntaxMacros

enum VersionRequirement {
	private static let versionGatedPropertyTypeName = "VersionGatedProperty"

	private static func versionGatedPropertyType(for wrappedType: TypeSyntax) -> IdentifierTypeSyntax {
		IdentifierTypeSyntax(
			name: TokenSyntax(stringLiteral: versionGatedPropertyTypeName),
			genericArgumentClause: GenericArgumentClauseSyntax {
				GenericArgumentSyntax(argument: wrappedType)
			}
		)
	}

	private static func binding(from declaration: some DeclSyntaxProtocol) throws -> PatternBindingSyntax {
		guard
			let variableDeclaration = declaration.as(VariableDeclSyntax.self),
			let binding = variableDeclaration.bindings.first,
			variableDeclaration.bindings.count == 1
		else {
			throw VersionRequirementError("\(Self.self) must be attached to a single variable declaration")
		}

		return binding
	}

	private static func type(from binding: PatternBindingSyntax) throws -> TypeSyntax {
		guard let typeAnnotation = binding.typeAnnotation else {
			throw VersionRequirementError("\(Self.self) requires a type annotation")
		}
		return typeAnnotation.type
	}

	private static func computedPropertyPattern(from binding: PatternBindingSyntax) throws -> IdentifierPatternSyntax {
		guard let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
			throw VersionRequirementError("\(Self.self) requires an identifier")
		}
		return identifierPattern
	}

	private static func storedPropertyPattern(for computedPropertyIdentifier: TokenSyntax) -> IdentifierPatternSyntax {
		IdentifierPatternSyntax(identifier: "_\(computedPropertyIdentifier)")
	}

	private static func versionNumber(from node: AttributeSyntax) throws -> IntegerLiteralExprSyntax {
		guard
			let arguments = node.arguments,
			case .argumentList(let list) = arguments,
			let firstArgument = list.first,
			let versionNumberSyntax = firstArgument.expression.as(IntegerLiteralExprSyntax.self)
		else {
			throw VersionRequirementError("\(Self.self) requires a version number argument")
		}
		return versionNumberSyntax
	}
}

extension VersionRequirement: PeerMacro {
	static func expansion(
		of node: AttributeSyntax,
		providingPeersOf declaration: some DeclSyntaxProtocol,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let versionNumber = try versionNumber(from: node)
		let binding = try binding(from: declaration)
		let type = try type(from: binding)
		let computedPropertyPattern = try computedPropertyPattern(from: binding)
		let storedPropertyPattern = storedPropertyPattern(for: computedPropertyPattern.identifier)

		let storeDeclaration = DeclSyntax(
			VariableDeclSyntax(
				bindingSpecifier: .keyword(.let),
				bindings: PatternBindingListSyntax(
					[
						PatternBindingSyntax(
							pattern: storedPropertyPattern,
							typeAnnotation: TypeAnnotationSyntax(
								type: versionGatedPropertyType(for: type)
							),
							initializer: binding.initializer
						)
					]
				)
			)
		)

		let apiVersionReference = DeclReferenceExprSyntax(baseName: "apiVersion")
		let closureReference = DeclReferenceExprSyntax(baseName: "closure")

		let decodingFunctionDeclaration = DeclSyntax(
			FunctionDeclSyntax(
				modifiers: DeclModifierListSyntax {
					DeclModifierSyntax(name: .keyword(.private))
					DeclModifierSyntax(name: .keyword(.static))
				},
				name: computedPropertyPattern.identifier,
				signature: FunctionSignatureSyntax(
					parameterClause: FunctionParameterClauseSyntax {
						FunctionParameterSyntax(
							firstName: apiVersionReference.baseName,
							type: OptionalTypeSyntax(wrappedType: TypeSyntax("Int")),
							trailingComma: .commaToken()
						)
						FunctionParameterSyntax(
							firstName: closureReference.baseName,
							type: FunctionTypeSyntax(
								parameters: [],
								effectSpecifiers: TypeEffectSpecifiersSyntax(throwsSpecifier: .keyword(.throws)),
								returnClause: ReturnClauseSyntax(type: type)
							)
						)
					},
					effectSpecifiers: FunctionEffectSpecifiersSyntax(
						throwsSpecifier: .keyword(.throws)
					),
					returnClause: ReturnClauseSyntax(
						type: versionGatedPropertyType(for: type)
					)
				),
				body: CodeBlockSyntax {
					CodeBlockItemListSyntax {
						CodeBlockItemSyntax(
							item: CodeBlockItemSyntax.Item(
								TryExprSyntax(
									expression: FunctionCallExprSyntax(
										calledExpression: ExprSyntax(stringLiteral: versionGatedPropertyTypeName),
										leftParen: .leftParenToken(),
										arguments: LabeledExprListSyntax {
											LabeledExprSyntax(label: "current", expression: apiVersionReference)
											LabeledExprSyntax(label: "required", expression: versionNumber)
											LabeledExprSyntax(label: "value", expression: closureReference)
										},
										rightParen: .rightParenToken()
									)
								)
							)
						)
					}
				}
			)
		)

		return [storeDeclaration, decodingFunctionDeclaration]
	}
}

extension VersionRequirement: AccessorMacro {
	static func expansion(
		of node: AttributeSyntax,
		providingAccessorsOf declaration: some DeclSyntaxProtocol,
		in context: some MacroExpansionContext
	) throws -> [AccessorDeclSyntax] {
		let binding = try binding(from: declaration)
		let computedPropertyPattern = try computedPropertyPattern(from: binding)
		let storedPropertyPattern = storedPropertyPattern(for: computedPropertyPattern.identifier)

		return [
			AccessorDeclSyntax(
				accessorSpecifier: .keyword(.get),
				effectSpecifiers: AccessorEffectSpecifiersSyntax(throwsSpecifier: .keyword(.throws)),
				body: CodeBlockSyntax {
					CodeBlockItemSyntax(
						item: CodeBlockItemSyntax.Item(
							TryExprSyntax(
								expression: MemberAccessExprSyntax(
									base: ExprSyntax(stringLiteral: storedPropertyPattern.identifier.text),
									name: "unwrapped"
								)
							)
						)
					)
				}
			)
		]
	}
}

struct VersionRequirementError: Error, CustomStringConvertible {
	let message: String
	var description: String { message }
	init(_ message: String) { self.message = message }
}
