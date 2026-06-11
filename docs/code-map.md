# NJU Timenote Code Map

This map records the Flutter frontend structure and the usual entry points for future agents.

## App Entry

- `lib/main.dart`: starts `TimenoteApp`.
- `lib/app/app.dart`: root `MaterialApp`, theme, route wiring, and `AppScope` for repositories.
- `lib/app/router.dart`: named routes and route argument objects.

## Theme And Design Tokens

- `lib/app/theme/app_theme.dart`: global light theme and preferred Source Han Serif font family.
- `lib/app/theme/app_colors.dart`: color tokens from the Pencil prototype.
- `lib/app/theme/app_spacing.dart`: spacing tokens.
- `lib/app/theme/app_shadows.dart`: shared card and overlay shadows.
- `assets/fonts/README.md`: font asset placement note. Add the real Source Han Serif files and OFL license here when available.

## Shared Widgets

- `lib/core/widgets/gradient_page_scaffold.dart`: common white page with top 225px blue-purple-pink gradient.
- `lib/core/widgets/app_header.dart`: page title/header row.
- `lib/core/widgets/app_card.dart`: white card with prototype-like shadow.
- `lib/core/widgets/app_bottom_input_bar.dart`: quick-pick, one-line input, and search bottom bar.
- `lib/core/widgets/create_todo_sheet.dart`: task-1 create-todo bottom sheet shell.
- `lib/core/widgets/app_dialogs.dart`: confirm dialog and picker shell.
- `lib/core/widgets/right_sidebar_shell.dart`: right-side sidebar shell.
- `lib/core/widgets/state_views.dart`: empty/loading/error/disabled states.
- `lib/core/widgets/placeholder_page.dart`: temporary route shell for future tasks.

## Data Boundary

- `lib/data/models/`: contract-shaped models for course, todo, settings, recommendation, and goal split.
- `lib/data/repositories/`: repository interfaces plus local repository factory.
- `lib/data/sources/local/`: local source skeletons. They currently return empty app state.
- `lib/data/sources/mock/`: mock boundary placeholder. Mock data is disabled by default.
- `lib/data/sources/remote/`: future backend boundary placeholder. UI must not call it directly.

## Feature Pages

- `lib/features/home/home_page.dart`: task-1 home screen and main navigation.
- `lib/features/settings/settings_page.dart`: minimal settings entry with schedule/rest and data/share sections.
- `lib/features/schedule/`: schedule and add-schedule placeholder routes for task 2.
- `lib/features/todo/`: todo list/detail/search placeholder routes for tasks 3 and 4.
- `lib/features/recommendation/`: next-thing placeholder route for task 4.
- `lib/features/goal_split/`: goal split placeholder route for task 4.

## Common Change Paths

- Add or change a route: read `lib/app/router.dart`, then the target feature page.
- Adjust prototype-wide colors, shadows, radius, or typography: change `lib/app/theme/` and shared widgets.
- Add business data access: define/extend a repository in `lib/data/repositories/`, implement it through a source, then inject via `RepositoryFactory`.
- Build a new page from the prototype: reuse `GradientPageScaffold`, `AppHeader`, `AppCard`, and state views before creating page-specific components.

## Boundaries

- Do not modify `docs/frontend-backend-contract.md` without product/backend approval.
- UI widgets should not access HTTP, databases, files, or platform storage directly.
- Do not place fake business examples inside UI widgets. Use mock/fake sources only when a task explicitly needs fixtures.
