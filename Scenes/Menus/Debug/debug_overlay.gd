class_name DebugOverlay
extends Control


@onready var fps_label: Label = %FPSLabel
@onready var position_label: Label = %PositionLabel
@onready var rotation_label: Label = %RotationLabel
@onready var vaults_label: Label = %VaultsLabel
@onready var save_label: Label = %SaveLabel
@onready var light_count_label: Label = %LightCountLabel
@onready var load_label: Label = %LoadLabel

var light_count: int = 0


var overlay_layer: int = 0:
	set(value):
		overlay_layer = value
		fps_label.show()
		if value < 2:
			position_label.hide()
			rotation_label.hide()
			vaults_label.hide()
		if value >= 2:
			position_label.show()
			rotation_label.show()
			vaults_label.show()
		if value < 3:
			save_label.hide()
			light_count_label.hide()
			load_label.hide()
		if value >= 3:
			save_label.show()
			light_count_label.show()
			load_label.show()


func _ready() -> void:
	position_label.hide()
	rotation_label.hide()
	vaults_label.hide()
	save_label.hide()
	light_count_label.hide()
	load_label.hide()


func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	
	if overlay_layer >= 2:
		if GameManager.player_character:
			vaults_label.text = "Vault: " + str(GameManager.player_character.vault_checks.vault_error)
			position_label.text = "Pos: " + str(GameManager.player_character.global_position)
			rotation_label.text = "Rot: " + str(GameManager.player_character.head.global_rotation)
	
	if overlay_layer >= 3:
		save_label.text = "SaveBlockers: " + str(SaverLoader.can_save)
		light_count = 0
		for light in get_tree().get_nodes_in_group("DynamicLights"):
			if light.visible:
				light_count += 1
		light_count_label.text = "LightCount: " + str(light_count)
		load_label.text = "Load: " + SaverLoader.progress_message
