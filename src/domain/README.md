# Domain

Pure GDScript rules and validators live here, split into `gameplay/` and
`formula_sandbox/` when each is ported. No gameplay implementation is present yet.

Inputs and outputs are JSON-compatible dictionaries/arrays and scalar values.
RefCounted is allowed for lifetime management; scene nodes and engine I/O are not.
Transitions return `{ok, state, events}` or `{ok: false, error}`. Errors contain
technical codes and, where appropriate, catalog keys/parameters. No text rendering.

The ruleset validator owns state schema and numeric constraints. `GameSession`
owns the live state. Walking, animation, camera motion, and lighting never advance
the calendar. Keep the two source rulesets' calendars, scores, and saves separate.

See [architecture](../../docs/ARCHITECTURE.md) and
[Chapter 2](../../docs/migration/chapters/02-gameplay-domain.md).
