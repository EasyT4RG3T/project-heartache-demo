class_name DebugOverlay
extends Control


@onready var fps_label: Label = %FPSLabel
@onready var position_label: Label = %PositionLabel
@onready var rotation_label: Label = %RotationLabel
@onready var vaults_label: Label = %VaultsLabel
@onready var interact_label: Label = %InteractLabel


var overlay_layer: int = 0:
	set(value):
		overlay_layer = value
		fps_label.show()
		if value < 2:
			position_label.hide()
			rotation_label.hide()
			vaults_label.hide()
			interact_label.hide()
		if value >= 2:
			position_label.show()
			rotation_label.show()
			vaults_label.show()
			interact_label.show()
		if value < 3:
			pass
		if value >= 3:
			pass


func _ready() -> void:
	position_label.hide()
	rotation_label.hide()
	vaults_label.hide()
	interact_label.hide()


func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	
	if overlay_layer >= 2:
		if GameManager.player_character:
			vaults_label.text = "Vault: " + str(GameManager.player_character.vault_checks.vault_error)
			position_label.text = "Pos: " + str(GameManager.player_character.global_position)
			rotation_label.text = "Rot: " + str(GameManager.player_character.head.global_rotation)
			interact_label.text = "Interact: " + str(GameManager.player_character.interact_type)
	
	if overlay_layer >= 3:
		pass
