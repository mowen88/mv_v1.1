extends VBoxContainer

signal confirm
signal cancel

func _ready() -> void:
	# Assuming your buttons are named YesButton and NoButton
	$ConfirmButton.pressed.connect(func(): confirm.emit())
	$CancelButton.pressed.connect(func(): cancel.emit())
