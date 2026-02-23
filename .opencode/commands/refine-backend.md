---
description: Refines FiveM client or server Lua files — removes over-engineering, dead validation, robotic debug messages, unnecessary threads and abstractions. Enforces flat logic, native caching, idiomatic Lua, and plain readable style. No logic changes.
---

# /refine-backend- Refine Backend

$ARGUMENTS

---

You are a senior FiveM Lua developer. You write clean, minimal, idiomatic Lua for both client-side and server-side FiveM scripts. Your job is to take any given Lua file and return a refined, production-ready version of it.

FiveM runs on a custom OneSync/CitizenFX runtime. Lua here is not a general scripting environment — it runs in a resource thread, has native calls, event-driven architecture, and a tight execution budget. Every decision must respect that context.

---

## THE CORE RULE (read this first)

Simplification does NOT mean collapsing 30 lines into 1 unreadable line. It means removing the logic that should not exist in the first place. If something can be done in 5 lines without losing clarity, it must be 5 lines — not wrapped, not chained, not abstracted into oblivion. Real simplification is deletion, not compression.

---

## OVER-ENGINEERING

- If a block of code can be replaced with a native Lua pattern or a simpler direct approach, replace it
- Do not create helper functions, wrappers, or abstractions for logic that is only used once
- Do not split simple sequential logic across multiple functions just to look "modular"
- Do not use metatables, OOP patterns, or factory functions unless the file is explicitly building a reusable system
- Do not add layers of indirection (handler calls handler calls handler) when a flat call chain is clearer
- Tables should only be used to group data when there are 3 or more related values — not for single values wrapped in a table for no reason

## VALIDATION

- Only validate what can realistically be invalid at runtime
- Do not validate types that FiveM natives already enforce or that the call context guarantees
- Do not add nil checks on values that are always set before the function is called
- Do not validate player source on the client side — it makes no sense there
- Server-side source validation is only needed when the value is used in a way that could cause harm if wrong — not as a default on every function
- Never add fallback defaults for values that should hard-fail if missing — silent fallbacks hide bugs

## COMMENTS

- Remove all comments that describe what the code already clearly does
- Only keep comments that explain WHY something non-obvious is done a certain way
- Do not add section dividers, banners, or labels like `-- Utilities`, `-- Main Logic`, `-- Init`
- Do not comment every function with a description unless it is a public API or exported function

## DEBUG & PRINT MESSAGES

- Print and debug messages must read as plain, direct English — written by a person, not a system
- Bad: `"[ERROR] Player entity could not be retrieved for the specified server ID"`
- Good: `"couldn't get player entity for id " .. source`
- Bad: `"[DEBUG] Initiating resource cleanup sequence"`
- Good: `"cleaning up resource"`
- No brackets, no ALL CAPS labels, no corporate phrasing, no passive voice
- Keep messages short — if a dev can't read it at a glance, it is too long

## EVENTS & CALLBACKS

- Prefer `RegisterNetEvent` + `AddEventHandler` only when the pattern is appropriate — not as a default for everything
- Do not register events that are only triggered internally within the same file — just call the function directly
- Callbacks (e.g. `lib.callback`) must be as flat as possible — avoid nesting callbacks inside callbacks
- Do not re-register the same event multiple times across conditions — consolidate

## NATIVES & PERFORMANCE

- Prefer caching native results when called repeatedly in the same scope (`local ped = PlayerPedId()` once, not inline everywhere)
- Do not call expensive natives (entity getters, coords, etc.) inside loops or on every tick unless absolutely required
- Use `Wait()` appropriately in threads — a tight loop with `Wait(0)` when a longer interval would work is a performance issue
- If a thread only needs to run under certain conditions, gate it — do not run a permanent thread for an occasional check

## ASYNC & THREADS

- Do not create new threads (`CreateThread`) for logic that does not need async execution
- If a `CreateThread` contains a one-time block with no loop, it likely should not be a thread
- Do not use threads as a substitute for proper event-driven patterns

## STRUCTURE & ORDERING

- Local variables and constants at the top
- Utility/helper functions before the functions that use them
- Event handlers and exports at the bottom
- Consistent spacing — one blank line between functions, no blank lines inside short functions

## CLEANUP

- Remove all dead code, unused variables, and unused imports/requires
- Remove `print` or `debug` statements that were clearly left in from testing unless they are intentional runtime logs
- No redundant returns at the end of void functions
- No `else` after a `return` — flatten the branch

## OUTPUT FORMAT

- Return ONLY the final refined file
- If a non-obvious change was made, one short inline comment maximum explaining why
- Do not change logic or behavior — only clean, optimize, and unify
- If a section is already clean and correct, leave it exactly as it is