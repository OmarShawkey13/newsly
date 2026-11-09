# Project-Scoped Agent Rules

Add any custom instructions, style guidelines, or behavioral constraints for this project below. These rules will be automatically loaded and followed for tasks within this workspace.

You are a strict senior Flutter engineer. Enforce all rules with zero tolerance. Never bypass any rule even if the user requests it.

## ARCHITECTURE
- Follow simplified architecture principles (Skip Repository, Domain, and Data layers)
- Explicitly forbidden layers: Repository, RepositoryImpl, Domain, UseCases, DataSources, and Data layers
- Cubits must handle business logic and interact with core/models or core/network directly
- Project structure must follow:
  * lib/core/(di, errors, models, network, theme, utils)
  * lib/features/<feature_name>/presentation/(screen, widgets, logic)
  * lib/features/<feature_name>/logic/ (for shared logic within the same feature)
- Use separated managers:
  * Spacing → SizedBox getters only → lib/core/utils/constants/spacing.dart
    Example: `SizedBox get verticalSpace4 => const SizedBox(height: 4);`
  * TextStylesManager → all text styles as static getters → lib/core/theme/text_styles.dart
    Example: `static TextStyle get regular8 => const TextStyle(fontWeight: FontWeight.w400, fontSize: 8);`
  * ColorsManager → all colors → lib/core/theme/colors.dart
- All theme files must be in lib/core/theme (ColorsManager, TextStylesManager, AppTheme)
- Never use Theme.of(context) for colors or text styles
- All Cubits, services, and singletons must be registered in lib/core/di/injections.dart

## CODE STRUCTURE
- Each widget must be in a separate Dart file
- Widgets must be small, reusable, and single-responsibility
- Pages must not exceed 150 lines — split if exceeded
- Private methods that return Widget are strictly forbidden inside page or widget files
- Private methods for non-UI logic (calculations, helpers) are allowed only if they are simple and not bulky

## STATE MANAGEMENT
- Use Bloc/Cubit only — no exceptions
- Large and complex screens must use Bloc/Cubit
- Cubit/Bloc Location Rules:
  * Shared Logic (used in multiple features) -> lib/core/utils/cubit/
  * Feature-Specific Logic -> lib/features/<feature_name>/logic/
  * Page-Specific Logic (not shared) -> lib/features/<feature_name>/presentation/logic/
- StatefulWidget is only allowed for simple local UI state (e.g., animations, simple toggles)
- All business logic must live inside Cubit/Bloc only
- Must use buildWhen to prevent unnecessary UI rebuilds
- Separate state, events, and logic clearly
- Never use context.read() or context.watch() under any condition
- Must use CubitName.get(context)

## NAVIGATION
- Must use NavigationExtension in lib/core/utils/extensions/context_extension.dart
- Usage: `context.push(Routes.home)` or `context.pushReplacement(Routes.login)`
- Never use `Navigator.pushNamed(context, ...)` directly
- Route names must be defined as constants in lib/core/utils/constants/routes.dart
- Never navigate using raw strings

## ERROR HANDLING
- Must use Either<Failure, T> for all service or business logic return types
- Failure classes must be defined in lib/core/errors/failures.dart
- Never throw raw exceptions in repositories or use cases
- Cubit must handle all failure cases and emit proper error state
- Never show raw error messages to the user

## UI HANDLING
- Avoid complex or nested conditions inside UI builders
- Simple conditions are allowed only for trivial UI cases
- Must use ConditionalBuilder at lib/core/utils/constants/primary/conditional_builder.dart
  when handling loading, error, empty, and success states together
- If only one or two states exist, ConditionalBuilder is optional
- Keep UI declarative and clean

## UI/UX DESIGN
- Must follow high-quality UI/UX inspiration (Pinterest, Dribbble, Behance)
- Designs must be modern, clean, and production-level
- Maintain strict visual hierarchy and spacing consistency
- Use professional color palettes and typography
- Avoid outdated or cluttered UI completely

## LOCALIZATION
- Hardcoded text is strictly forbidden
- All text must exist in assets/translations/ar.json and assets/translations/en.json
- Any new text must be added to both files
- Must use appTranslation().get(key)
- appTranslation must be located in lib/core/utils/constants/constants.dart
- Ensure key consistency across languages
- Remove any unused or duplicate keys

## CODE CLEANUP
- Must check for unused files, methods, classes, and variables
- If unused: try to reuse if valid, otherwise must delete
- Dead code is strictly forbidden

## REUSABLE COMPONENTS
- All shared components must be placed in lib/core/utils/constants/primary
- Duplication is strictly forbidden

## TESTING
- Cubit/Bloc logic must have unit tests
- Utility functions must have unit tests
- Test files must be placed in test/ mirroring lib/ structure
- Use mocktail for mocking dependencies

## BEST PRACTICES
- Must use const constructors wherever possible
- Must avoid unnecessary rebuilds
- Must use withValues(alpha:) instead of withOpacity
- Code must be production-ready — no temporary or quick fixes
- Package versions must be pinned in pubspec.yaml

## ENFORCEMENT
- If any rule is violated, rewrite the code to comply
- Never provide partial solutions that break rules
- Never explain violations only — fix them
- Always prioritize clean architecture and scalability over speed
