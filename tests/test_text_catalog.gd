extends "res://tests/test_suite.gd"

const CATALOG = preload("res://src/shared/text_catalog.gd")


func run() -> void:
	var catalog := CATALOG.new()
	var entries := {"test.line": "Hello {name}, {count}", "test.repeat": "{name}/{name}"}
	expect(catalog.set_catalog(entries)["ok"], "Valid catalog must register")
	entries["test.line"] = "changed"
	var resolved := catalog.format_text("test.line", {"name": "{count}", "count": 2})
	expect(resolved["text"] == "Hello {count}, 2", "Parameters must not be expanded recursively")
	expect(catalog.format_text("test.repeat", {"name": "A"})["text"] == "A/A", "Repeat parameters")
	expect(not catalog.format_text("missing")["ok"], "Missing keys must fail")
	expect(not catalog.format_text("test.line", {"name": "A"})["ok"], "Missing parameters must fail")
	expect(not catalog.set_catalog({"test.line": 10})["ok"], "Reject non-string catalog entries")
	expect(catalog.format_text("test.repeat", {"name": "A"})["ok"], "Failed catalog preserves old entries")
