/// A value describing an instance of Swift source code that is considered invalid by a SwiftLint rule.
public struct StyleViolation: CustomStringConvertible, Codable, Hashable {
    /// The identifier of the rule that generated this violation.
    public let ruleIdentifier: String

    /// The description of the rule that generated this violation.
    public let ruleDescription: String

    /// The name of the rule that generated this violation.
    public let ruleName: String

    /// The severity of this violation.
    public private(set) var severity: ViolationSeverity

    /// The location of this violation.
    public private(set) var location: Location

    /// The justification for this violation.
    public let reason: String

    /// A printable description for this violation.
    public var description: String {
        // {full_path_to_file}{:line}{:character}: {error,warning}: {content}
        [
            "\(location): ",
            "\(severity.rawValue): ",
            "\(ruleName) Violation: ",
            reason,
            " (\(ruleIdentifier))",
        ].joined()
    }

    /// Creates a `StyleViolation` by specifying its properties directly.
    ///
    /// - parameter ruleDescription: The description of the rule that generated this violation.
    /// - parameter severity:        The severity of this violation.
    /// - parameter location:        The location of this violation.
    /// - parameter reason:          The justification for this violation. If not specified the rule's description will
    ///                              be used.
    public init(ruleDescription: RuleDescription,
                severity: ViolationSeverity = .warning,
                location: Location,
                reason: String? = nil) {
        self.ruleIdentifier = ruleDescription.identifier
        self.ruleDescription = ruleDescription.description
        self.ruleName = ruleDescription.name
        self.severity = severity
        self.location = location
        self.reason = reason ?? ruleDescription.description
        #if DEBUG
        if self.reason.trimmingTrailingCharacters(in: .whitespaces).last == ".",
           RuleRegistry.shared.rule(forID: self.ruleIdentifier) != nil {
            queuedFatalError("""
                Reasons shall not end with a period. Got "\(self.reason)". Either rewrite the rule's description \
                or set a custom reason in the StyleViolation's constructor.
                """)
        }
        #endif
    }

    /// Returns the same violation, but with the `severity` that is passed in
    /// - Parameter severity: the new severity to use in the modified violation
    public func with(severity: ViolationSeverity) -> Self {
        var new = self
        new.severity = severity
        return new
    }

    /// Returns the same violation, but with the `location` that is passed in
    /// - Parameter location: the new location to use in the modified violation
    public func with(location: Location) -> Self {
        var new = self
        new.location = location
        return new
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}
