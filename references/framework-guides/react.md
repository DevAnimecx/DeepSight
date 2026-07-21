# React Hooks Patterns

## Rules
- Dependencies array must include ALL referenced variables
- No conditional hooks (no `if` before `useEffect`)
- No hooks inside loops or nested functions
- State updates must use functional form when depending on previous state

## Anti-Patterns
```jsx
// ❌ Conditional hook
if (user) {
  useEffect(() => { fetchUser(user.id); }, []);
}

// ❌ Missing dependency
useEffect(() => {
  fetchData(query);
}, []); // Missing `query`

// ❌ Hook inside loop
users.map(u => {
  const [count, setCount] = useState(0); // NO
});

// ❌ Stale closure
const [count, setCount] = useState(0);
useEffect(() => {
  const id = setInterval(() => {
    setCount(count + 1); // Always uses initial `count`
  }, 1000);
  return () => clearInterval(id);
}, []);
```

## Correct Patterns
```jsx
// ✅ All dependencies listed
useEffect(() => {
  fetchData(query);
}, [query]);

// ✅ Functional state update
setCount(c => c + 1);

// ✅ Conditional logic INSIDE effect
useEffect(() => {
  if (user) fetchUser(user.id);
}, [user]);
```


