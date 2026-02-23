---
description: Stages all changes, generates crisp Conventional Commit message, and pushes to current branch. One command, no arguments.
---

# /commit - Stage, Commit & Push

## Usage

```
/commit
```

One command. No arguments. Stages everything, commits, pushes.

---

## What It Does

1. **Check status** - git status
2. **Stage all** - git add .
3. **Analyze changes** - what files, what type of change
4. **Generate message** - Conventional Commit format
5. **Commit** - git commit
6. **Push** - git push origin <current-branch>

---

## Mixed Changes

When a single commit contains multiple types (feature + fix + refactor):

**Option 1: Use primary type + bullet points**
```
feat(auth): add login and fix validation

- Implement JWT authentication
- Fix token expiration check
- Refactor password hashing
```

**Option 2: Split into separate commits (preferred)**
If changes are independent, commit separately:
```
feat(auth): implement JWT authentication

(manually commit the fix separately)
fix(auth): resolve token expiration validation
```

**Type priority when mixed:**
1. `fix` - If there's any bug fix (highest priority)
2. `feat` - If there's new functionality
3. `refactor` - If restructuring code
4. `perf` - If optimizing
5. Others follow

---

## Commit Types

| Type | Use When | Example |
|------|----------|---------|
| `feat` | New feature | feat(auth): add login form |
| `fix` | Bug fix | fix(api): resolve timeout |
| `docs` | Documentation | docs(readme): update setup |
| `style` | Formatting | style(css): fix indentation |
| `refactor` | Restructure | refactor(utils): simplify helpers |
| `perf` | Performance | perf(queries): add index |
| `test` | Tests | test(auth): add login tests |
| `build` | Build/deps | build(deps): upgrade react |
| `chore` | Maintenance | chore(cleanup): remove logs |

---

## Message Rules

- **Format:** `<type>(<scope>): <description>`
- Start with verb (add, fix, update, remove, implement)
- Imperative mood ("add" not "added")
- No period at end
- Keep under 72 chars for subject

---

## Output

**Success:**
```
✓ Committed to feature/auth
  feat(auth): add login and fix validation
  3 files changed, +142 -12
  
✓ Pushed to origin/feature/auth
```

**Nothing to commit:**
```
Nothing to commit. Working tree clean.
```

**Failure:**
```
✗ Commit failed
  error: failed to push some refs to 'origin'
  hint: Updates were rejected because the tip of your current branch is behind

Run: git pull && /commit
```

---

## Examples

**Single type:**
```
feat(auth): implement JWT login with validation
```

**Mixed types:**
```
feat(auth): add authentication and fix validation errors

- Implement JWT-based login system
- Fix token expiration validation bug
- Refactor password hashing for security
```

**Complex mixed changes:**
```
feat(payments): integrate stripe with fixes and tests

Features:
- Add Stripe payment gateway integration
- Implement payment intent creation

Fixes:
- Resolve currency formatting issue
- Fix payment status sync bug

Tests:
- Add unit tests for payment flow
- Add integration tests for webhooks
```

---

**Rules:**
- Prioritize `fix` over `feat` when bugs are involved
- Use bullet points to describe different changes
- Keep commits atomic when possible (separate commits for separate concerns)
- Conventional Commits format always
- Crisp messages, no fluff
