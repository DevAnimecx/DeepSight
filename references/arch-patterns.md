# Architecture Patterns — DeepSight Reference

## Hexagonal Architecture (Ports & Adapters)

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Controllers│     │   Services   │     │  Repositories│
│  (Primary    │────▶│  (Domain     │────▶│  (Secondary  │
│   Adapters)  │     │   Logic)     │     │   Adapters)  │
└──────────────┘     └──────┬──────┘     └──────────────┘
                            │
                     ┌──────▼──────┐
                     │   Ports     │
                     │ (Interfaces)│
                     └─────────────┘
```

### Rules
- Domain layer has ZERO imports from infrastructure
- Controllers adapt HTTP → domain calls
- Repositories adapt DB → domain interfaces
- Services contain ONLY business logic

### Anti-Patterns
- Controller calling DB directly (skips domain)
- Service importing ORM models (tight coupling)
- Domain importing framework types (React, Express)

## Clean Architecture (Uncle Bob)

### Dependency Rule
Source code dependencies point INWARD only.
Inner layers know nothing about outer layers.

### Layers
1. **Entities**: Core business objects
2. **Use Cases**: Application-specific business rules
3. **Interface Adapters**: Controllers, presenters, gateways
4. **Frameworks & Drivers**: DB, UI, external APIs

### Dependency Injection
- Inject dependencies via constructor/interface
- Never `new` concrete classes inside domain logic

## God Object Detection

### Thresholds
- **>500 LOC**: Flag as god object candidate
- **>20 public methods**: Definitely a god object
- **>3 responsibilities** (violates SRP)

### Refactoring Strategies
1. Extract domain concepts into separate classes
2. Split by responsibility (auth vs. data vs. formatting)
3. Use composition over inheritance
4. Introduce event-driven communication between sub-domains

## Circular Dependency Detection

### Detection Pattern
If A imports B, B imports C, and C imports A → circular dependency.

### Resolution
1. Extract shared types into a common module
2. Use dependency injection instead of direct imports
3. Introduce interfaces/ports to break the cycle


