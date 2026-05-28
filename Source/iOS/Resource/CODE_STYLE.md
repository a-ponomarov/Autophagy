# Unified Swift Rules

## 1. Core Principles

- Optimize for clarity at the call site.
- Prefer readability over brevity.
- Prefer consistency over personal preference.
- Prefer simple solutions over clever ones.
- Redesign APIs that are hard to explain simply.

## 2. Documentation

- Document every public and open declaration.
- Document non-obvious internal declarations.
- Use `///` comments only.
- Start with a one-line summary ending with a period.
- Use tags in this order: `Parameters`, `Returns`, `Throws`.
- Document complexity when not `O(1)`.

## 3. Naming and Types

- Use names that describe purpose, not type.
- Omit redundant words and avoid custom abbreviations.
- Use standard industry terms.
- Boolean names must read as assertions using `is`, `has`, or `can`.
- Types and protocols use `UpperCamelCase`.
- Everything else uses `lowerCamelCase`.
- Prefer `struct` by default.
- Use `class` only for reference semantics or inheritance.
- Use `enum` for fixed states and caseless enums for namespaces.
- Use protocols for abstractions and nested types for scoped relationships.

## 4. Files and Source Layout

- File extension must be `.swift`.
- File name must match the primary type or purpose.
- Prefer one primary type per file.
- Use `Type+Capability.swift` for extensions.
- Keep declarations logically ordered.
- Swift source files must start with one blank first line followed immediately by imports.
- Do not add generated file header comments.
- Use `// MARK:` for sections.
- Put required parameters first and defaulted parameters last.
- Prefer default values over many overloads.

## 5. Project Structure

- Organize code by target root first, for example `iOS` and `Shared`.
- Use stable first-level groups: `Module`, `Service`, `Model`, `View`, `Extension`, `Resource`.
- Keep app composition files at the target root.
- Add a new top-level group only when existing groups cannot express ownership clearly.
- Do not introduce catch-all folders like `Helpers`, `Utils`, `Common`, `Core`, or `Misc`.

### Module

- Use `Module` for user-facing features and complete flows.
- Create one folder per feature, for example `Module/Feature`.
- Keep the feature entry screen at the feature root, for example `FeatureView.swift`.
- Keep the feature view model at the feature root when it directly drives the screen.
- Put screen-specific UI parts in `Components` under the feature folder.

### View

- Use `View` only for reusable presentation not owned by a single feature.
- Group shared views by domain when useful, for example `View/Audio`.
- Use `View/Components` for generic reusable UI.
- Do not place feature entry screens in `View`.

### Service

- Use `Service` for orchestration, persistence, networking, coordination, audio, store, and other
  side-effecting logic.
- Create one subfolder per subsystem, for example `Service/Playback`, `Service/Persistence`.
- Add nested technical groups only when needed, for example `Action`, `Model`, or `Intent`.
- Keep subsystem-local models inside that subsystem instead of promoting them too early.

### Model

- Use top-level `Model` for shared domain entities and value types.
- Use nested `Model` folders inside a feature or service for scope-local types.

### Extension

- Use `Extension` only for type extensions.
- Keep extensions in the nearest shared scope that matches their usage.

### Resource

- Use `Resource` for assets, fonts, colors, strings, entitlements, plists, StoreKit files, and
  other bundled files.
- Keep resources inside the owning target or subtarget.
- Do not mix bundled resources and source code in the same feature folder.

## 6. Modern iOS Defaults

- For new Apple-platform projects targeting iOS 26+, prefer the latest native Apple stack.
- Default UI framework is `SwiftUI`.
- Default app lifecycle is the `App` protocol.
- Prefer native Apple SDKs before third-party abstractions when platform APIs already cover the need.
- Introduce UIKit bridging only when SwiftUI still lacks the required capability.

### State and Concurrency

- Use `@Observable` for shared mutable reference state by default.
- Use `@State` for view-owned local state, including owned observable models.
- Use `.environment(...)` and `@Environment(Type.self)` for shared app dependencies.
- Use `@Bindable` only when a view needs writable bindings into an observable model.
- Treat `ObservableObject` and `@Published` as legacy compatibility tools, not defaults.
- Use Swift Concurrency by default.
- Prefer `async` / `await`, `Task`, `AsyncSequence`, and actors over callbacks or Combine.
- Mark UI-facing observable reference types with `@MainActor` when they mutate SwiftUI state.

### Persistence and System SDKs

- Prefer `SwiftData` for new persistence layers unless another storage system is clearly justified.
- Use `@Model` for persisted reference models owned by SwiftData.
- Keep pure domain value types as `struct` when persistence identity is not required.
- Use `AppIntents` for system-exposed app actions.
- Use `WidgetKit` for widgets and `ActivityKit` for Live Activities.
- Prefer native system capabilities such as StoreKit, TipKit, Swift Charts, and FoundationModels
  when they fit the product requirement.

## 7. Architecture and DI

- Follow a composition-root architecture.
- Create all long-lived app services in one root container, for example `ApplicationContainer`.
- Keep startup wiring in the app target root, not inside feature views.
- Do not introduce a DI framework by default.
- Prefer explicit constructor injection and SwiftUI environment injection over service locators.

### Composition Root

- The root `App` type owns a single container instance in `@State`.
- The container constructs concrete services, coordinators, stores, and shared view models.
- The container may perform startup-only setup and observation bridges between root services.
- Root flow switching belongs to the container plus coordinator/store layer, not to leaf views.

### Coordinator and Navigation

- Use one app-level coordinator as the source of truth for navigation and presentation.
- The coordinator must be `@Observable` and environment-injected.
- The coordinator owns root selection, selected tab, navigation paths, and modal destinations.
- Model navigation with typed enums and `NavigationPath`.
- Views update coordinator state instead of re-implementing routing logic locally.
- Business logic does not live in the app coordinator.

### Feature Modules

- Each feature owns its entry view and, when needed, a feature-specific view model.
- Feature views stay focused on rendering, bindings, local presentation state, and lifecycle hooks.
- Feature view models own presentation logic, user intent handling, derived state, and service
  coordination for one feature.
- Create a feature view model in `@State` when the feature view owns its lifetime.
- Pass only the dependencies needed to construct the feature view model.

### Services and State Flow

- Put side effects and operational logic in `Service`, not in SwiftUI views.
- Split larger subsystems into small collaborators with narrow responsibilities.
- For non-trivial flows, keep mutable workflow state in dedicated state models.
- Extract transition logic into focused helpers or state-machine types when a feature has several
  statuses or actions.
- Prefer explicit action-oriented helpers when they map to real workflow transitions.

### Persistence Boundary

- Centralize persistent data access behind a dedicated persistence service or actor.
- Keep domain-specific persistence operations in focused files rather than one monolith.
- Views should not talk to `SwiftData` directly when a feature already has a service boundary.
- Persisted writes should happen through services or view models that can handle rollback, recovery,
  and logging.

### Replaceability

- Constructor-injected services must remain replaceable by test doubles.
- Keep business rules in services, coordinators, and state helpers so they can be exercised without
  rendering SwiftUI views.

## 8. Formatting

- Use spaces only; do not use tabs.
- Use 2 spaces per indent level.
- Maximum line length is 100 characters unless wrapping harms readability.
- Use K&R braces.
- Use one blank line between logical sections and type members.
- Do not use multiple consecutive blank lines.
- Use one space around binary operators and after commas.
- Do not align code with extra spaces.
- One statement per line; do not use semicolons.
- Prefer multiline blocks over single-line blocks.

## 9. Properties and Control Flow

- Use `let` unless mutation is required.
- Keep mutation local.
- Mutating methods use verbs; nonmutating equivalents use `ed` or `ing` forms where natural.
- Omit `get` for read-only computed properties.
- Prefer synthesized memberwise initializers.
- Do not write unnecessary initializers.
- Use `self.` only for disambiguation or clarity.
- Omit `.init` when the type is explicit.
- Use `guard` for early exits.
- Reduce nesting depth.
- Prefer exhaustive `switch` statements and avoid `fallthrough`.

## 10. Optionals, Errors, and Performance

- Use optionals for absence of value; do not use sentinel values.
- Use `throw` for multiple failure states.
- Avoid `try!`, force unwraps, and force casts in production code.
- Use implicitly unwrapped optionals only when required by lifecycle constraints.
- Avoid custom operators unless the meaning is obvious and natural.
- Prefer methods over expensive computed properties.
- Do not hide heavy work behind property access.
- Document non-trivial performance costs and overflow arithmetic usage.
