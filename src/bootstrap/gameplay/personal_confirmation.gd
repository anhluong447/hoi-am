extends RefCounted
## Concrete composition of the existing personal-action confirmation dialog.


static func open(owner: Node, controller: RefCounted, text: RefCounted, command: Dictionary) -> void:
	var confirm := ConfirmationDialog.new()
	confirm.dialog_text = controller.romance_confirmation(command)
	confirm.ok_button_text = text.text("play.confirm")
	confirm.cancel_button_text = text.text("play.close")
	confirm.confirmed.connect(func() -> void:
		controller.execute(command)
		owner.open_workspace()
		confirm.queue_free())
	confirm.canceled.connect(func() -> void: confirm.queue_free())
	owner.add_child(confirm)
	confirm.popup_centered()
