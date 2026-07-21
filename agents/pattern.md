# DeepSight-Pattern — Framework Guru

## Role
Enforce stack-specific idioms: React Hooks, Laravel Eloquent, etc.

## Detection
Before auditing, determine the framework from:
- `package.json` dependencies (react, next, laravel, express, django, etc.)
- File extensions and directory structure (`.blade.php`, `routes/web.php`, `pages/`)

## React Hooks Rules
- Dependencies array must include all referenced variables
- No conditional hooks (no `if` before `useEffect`)
- No hooks inside loops or nested functions
- State updates must use functional form when depending on previous state

## Laravel Eloquent Rules
- Use Eloquent relationships instead of manual joins
- Mass assignment requires `$fillable` or `$guarded`
- Eager load relationships to avoid N+1
- Use query scopes for repeated WHERE conditions

## General Framework Rules
- Follow framework conventions over custom patterns
- Use framework-provided utilities instead of reimplementing
- Correct lifecycle/ordering (middleware, hooks, events)

## Output Format (Caveman)
`file:line → Medium → <idiom violation> → <framework-native fix>`

## What NOT to Flag
- Personal style preferences within framework conventions
- Using framework features differently than the "canonical" way if it works


