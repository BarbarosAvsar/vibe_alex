# Clean Code Guidelines for Swift (from MaatheusGois)

Source: https://github.com/MaatheusGois/clean-code-swift

## Variables
- Prefer meaningful, pronounceable names and keep the vocabulary consistent for the same concept (e.g., always `user`, never mixing with `client`).
- Replace “magic numbers” with named constants, add explanatory variables for complex expressions, and avoid mental mapping through single-letter identifiers.
- Keep contexts lean: don’t duplicate type information in the variable name (e.g., `user.address`, not `user.userAddress`).

## Functions
- Functions should do exactly one thing, be short, and describe their behavior through clear naming.
- Restrict argument lists (ideally ≤ 2) and leverage default parameters instead of boolean flags or short-circuit tricks.
- Avoid side effects (mutating shared state, writing globals) and type checks; rely on polymorphism and value semantics instead.

## Objects & Data Structures
- Hide implementation details, expose behavior instead of raw data, and treat structs/classes as pure objects without unexpected shared state.
- Fail fast and return early when guard conditions are not met.

## Classes
- Keep classes small, cohesive, and organized by responsibility; split logic when multiple reasons to change appear.
- Encapsulate conditionals and keep abstraction layers consistent—high-level classes should not micromanage implementation details.

## SOLID
- **Single Responsibility:** every type has one reason to change.
- **Open/Closed:** extend behavior via protocols/strategies rather than edits.
- **Liskov:** honor contracts when subclassing or conforming to protocols.
- **Interface Segregation:** prefer lean protocols over “mega” ones.
- **Dependency Inversion:** depend on abstractions and inject collaborators.

## Testing
- Tests should be readable, fast, deterministic, and isolated; name them after the behavior they cover.
- Use dependency injection or protocol-driven design to replace external services with fakes/mocks.

## Concurrency
- Treat shared mutable state with care; favor immutability or actor-like coordination primitives and keep async APIs explicit.

## Error Handling
- Prefer Swift’s typed `Error` over magic return codes, bubble errors with `throws`, and surface actionable information to callers.

## Formatting
- Keep files small, organize imports, leave meaningful whitespace, and align related declarations for scanability.

## Comments
- Eliminate the need for comments by writing self-explanatory code; when comments are required, keep them up to date and focused on intent rather than restating the code.
