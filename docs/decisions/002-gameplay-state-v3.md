# ADR 002 — Explicit keyed gameplay state v3

Accepted for the migration subset, 2026-10-10.

Source v2 embeds resolved roster/case/quest labels. Reusing those fields would
make the domain own translated display text. The Godot schema therefore advances
to version 3; no translated literals or text-service dependency enter the rules.

People replace `name` with `name_key`. Cases replace `title`, `story`, `teaser`
with their corresponding `_key` fields. Quest/draft/article titles use
`title_key` and optional `title_parameters`. IDs, balance, metrics and all numeric
gameplay behavior remain stable. Technical quest IDs are explicitly `Q<week>`;
they no longer depend on a translated ID template.

New events retain source `day`, `phase`, `textKey`, `params` structure. A param
may contain `{text_key, parameters}` or `{number, format: vi_integer}`.
`gameplay_text.gd` presentation formatting resolves these. Legacy event parameters
remain unchanged in migrated states; legacy rendered messages are retained.

`state_migration.gd` is pure and clones input. It recognizes v1/v2 roster/case
IDs, removes embedded display fields and maps legacy skill IDs to `synergy`.
Unknown versions and unmappable title IDs reject. The resulting v3 state must
pass `state_validation.gd` before `GameSession.replace`; replacement itself
accepts only valid v3 state. No migration bypass or storage side effect exists.

Validation covers config bounds, finite numbers, strict booleans, array shapes,
duplicate IDs, actor/stat/case/message/report references, log calendar/key/params,
title keys/params and JSON-compatible state. StringName dictionary keys produced
by GDScript dot assignment serialize as JSON strings; runtime objects/Callables
and excessive nesting reject. Optional boost/processed/publication fields are
checked when present. New fields require review in this decision and fixtures.

For parity, tests project v3 to the source v2 representation outside domain,
resolving only display fields/params. They compare every other field recursively:
exact integer, boolean, string and ID equality; floating tolerance `1e-8`; exact
array ordering including log/events. This is a schema adaptation, not a numeric
baseline regeneration. The source oracle files remain byte locked.

Full save envelopes, legacy world coordinates and disk import UX remain Chapter
09. This decision does not claim all possible historical saves are importable;
unknown content IDs reject rather than being guessed from translated labels.
