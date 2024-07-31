@attached(accessor, names: named(get))
@attached(peer, names: prefixed(_), overloaded)
macro VersionRequirement(_ version: Int) = #externalMacro(module: "TransmissionMacros", type: "VersionRequirement")
