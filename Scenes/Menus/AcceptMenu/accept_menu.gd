class_name AcceptMenu
extends Control


signal accepted
signal cancelled


@onready var label: Label = %Label
@onready var line_edit: LineEdit = %LineEdit
@onready var cancel: Button = %Cancel
@onready var accept: Button = %Accept

@export var editable: bool = false

@export var cancel_button: bool = true
@export var message: String = "Alert"
@export var placeholder_message: String = "Alert"
@export var accept_text: String = "Accept"
@export var cancel_text: String = "Cancel"


func take_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		cancel.pressed.emit()
	if event.is_action_pressed("enter"):
		accept.pressed.emit()


func _ready() -> void:
	if !editable:
		line_edit.hide()
		label.text = message
	else:
		label.hide()
		line_edit.placeholder_text = placeholder_message
		line_edit.text = message
	
	accept.text = accept_text
	accept.pressed.connect(func():
		accepted.emit())
	
	if cancel_button:
		cancel.text = cancel_text
		cancel.pressed.connect(func():
			cancelled.emit())
	else:
		cancel.hide()
