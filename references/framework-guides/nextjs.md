# Next.js App Router Patterns

## Rules
- Server Components by default, `'use client'` only when needed
- Proper data fetching in Server Components
- Proper caching and revalidation strategies
- Proper metadata API usage

## Anti-Patterns
```tsx
// ❌ Unnecessary 'use client'
export default function Page() {
  return <div>Static content</div>; // No client features needed
}

// ❌ Fetching in useEffect (client-side)
'use client';
export default function Page() {
  const [data, setData] = useState(null);
  useEffect(() => { fetch('/api/data').then(r => r.json()).then(setData); }, []);
}
```

## Correct Patterns
```tsx
// ✅ Server Component
export default async function Page() {
  const data = await fetch('https://api.example.com/data', { next: { revalidate: 3600 } });
  return <div>{/* render data */}</div>;
}
```


