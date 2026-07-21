# Laravel Eloquent Patterns

## Rules
- Use Eloquent relationships instead of manual joins
- Mass assignment requires `$fillable` or `$guarded`
- Eager load relationships to avoid N+1
- Use query scopes for repeated WHERE conditions

## Anti-Patterns
```php
// ❌ N+1 query
$users = User::all();
foreach ($users as $user) {
    echo $user->posts()->count(); // Query per user!
}

// ❌ Missing mass assignment protection
User::create($request->all()); // No $fillable!

// ❌ Raw join when relationship exists
$users = DB::table('users')
    ->join('posts', 'users.id', '=', 'posts.user_id')
    ->get();
```

## Correct Patterns
```php
// ✅ Eager loading
$users = User::with('posts')->get();

// ✅ Mass assignment with $fillable
protected $fillable = ['name', 'email'];

// ✅ Relationship + accessor
public function fullName() {
    return "{$this->first_name} {$this->last_name}";
}
```


