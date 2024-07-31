import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct TransmissionMacros: CompilerPlugin {
	var providingMacros: [Macro.Type] = [VersionRequirement.self]
}
