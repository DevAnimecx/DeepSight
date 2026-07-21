# Team Playbook — Project-Specific Conventions

> **Note**: This file should be customized per project. Copy from this template and fill in your team's actual conventions.

## Naming Conventions

### Files
- Components: `PascalCase.tsx` (e.g., `UserProfile.tsx`)
- Utilities: `camelCase.ts` (e.g., `formatDate.ts`)
- Services: `camelCase.service.ts` (e.g., `auth.service.ts`)
- Types: `camelCase.types.ts` or inline in consuming file

### Functions & Variables
- `camelCase` for functions and variables
- `PascalCase` for classes and components
- `UPPER_SNAKE_CASE` for constants

## Error Handling Policy

- All async functions must have try/catch or `.catch()`
- Errors must be logged with context (file:line, user ID if available)
- Never swallow errors silently
- Use custom error classes for domain errors

## API Design

- RESTful endpoints: `/api/v1/resource`
- Pagination: `?page=1&limit=20`
- Filtering: `?status=active&role=admin`
- Response format: `{ data: ..., meta: { total, page, limit } }`

## Database Conventions

- Table names: `snake_case` plural (e.g., `user_profiles`)
- Column names: `snake_case` (e.g., `created_at`)
- Foreign keys: `{singular_table}_id` (e.g., `user_id`)
- Indexes on: foreign keys, frequently queried columns, timestamps

## Testing Standards

- Unit tests for all business logic
- Integration tests for API endpoints
- E2E tests for critical user flows
- Test file naming: `{source}.test.ts` or `{source}.spec.ts`
- Minimum 80% coverage for business-critical modules

## Code Review Checklist

- [ ] No hardcoded secrets or credentials
- [ ] All new public methods have tests
- [ ] No circular dependencies introduced
- [ ] Performance impact assessed for DB changes
- [ ] Error handling covers all failure modes
- [ ] Input validation at all boundaries


