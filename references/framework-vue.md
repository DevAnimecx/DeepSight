# DeepSight Framework Guide — Vue.js

## Detection
- File patterns: *.vue, nuxt.config.*, vite.config.* with @vitejs/plugin-vue
- package.json: vue, vue-router, pinia, vuex, nuxt

## Key Vulnerabilities

### XSS via v-html
Flag Critical. Never use v-html with user input. Use safe interpolation instead.

### Missing Key in v-for
Flag High. Always add :key for stable list rendering.

### Mutating Props Directly
Flag High. Emit events instead of mutating props.

### Computed with Side Effects
Flag High. Computed values must be pure functions.

## Composition API Patterns

### Ref vs Reactive
- ref() for primitives (count, name, flag)
- reactive() for objects (state, config, form)
- Flag mixing both types in same component

### WatchEffect Cleanup
Flag missing onCleanup in watchEffect for timers, listeners, subscriptions.

## SFC Best Practices
- Vue 3: multiple root elements allowed in template
- Prefer script setup over Options API for new code
- Use scoped styles (<style scoped>) to prevent CSS leakage
- Use module styles (<style module>) for programmatic CSS access
