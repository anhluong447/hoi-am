extends Node

signal back_requested

const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const CONTROLLER = preload("res://src/presentation/controllers/calendar_controller.gd")
const HUD = preload("res://src/presentation/coastal/hud_view.tscn")
const PANEL = preload("res://src/presentation/previews/calendar_panel.tscn")

var controller: RefCounted
var session: RefCounted
var _hud: Control
var _panel: Control
var _dependencies: Dictionary


func _ready() -> void:
	var setup := STARTUP.prepare()
	if not setup.ok:
		push_error(str(setup.error))
		get_tree().quit(1)
		return
	session = setup.session
	_dependencies = setup
	controller = CONTROLLER.new(session, setup.text, setup.data.gameplay, setup.data.preview)
	var resources := STARTUP.ui_resources(setup.data)
	_hud = HUD.instantiate()
	_hud.configure(controller.model(), setup.data.hud_ui, resources)
	_hud.menu_requested.connect(func() -> void: back_requested.emit())
	$Interface.add_child(_hud)
	_panel = PANEL.instantiate()
	var copy: Dictionary = {}
	for definition: Dictionary in setup.data.preview.calendar_commands:
		copy[definition.id] = setup.text.text(definition.text_key)
	_panel.configure(copy, setup.data.preview.calendar_commands, resources["Source Serif 4"])
	_panel.command_requested.connect(_command)
	$Interface.add_child(_panel)


func _command(command: Dictionary) -> void:
	var outcome: Dictionary = controller.execute(command)
	_panel.show_message(outcome.message)
	_hud.render(controller.model())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		back_requested.emit()
