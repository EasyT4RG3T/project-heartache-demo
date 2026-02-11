class_name Cutscene
extends AnimationPlayer


@export var player_anim: Node3D
@export var exit_movement_mode: PlayerCharacter.MovementMode


func _ready() -> void:
	assert(player_anim, "No player_anim in cutscene node")
	animation_started.connect(func(_anim_name: StringName):
		GameManager.player_character.reparent(player_anim, false)
		GameManager.player_character.current_movement_mode = PlayerCharacter.MovementMode.CUTSCENE
		InputManager.player_character_input = false)
	animation_finished.connect(func(_anim_name: StringName):
		GameManager.player_character.reparent(Game)
		GameManager.player_character.current_movement_mode = exit_movement_mode
		match exit_movement_mode:
			PlayerCharacter.MovementMode.WALKING:
				pass
			PlayerCharacter.MovementMode.SPRINTING:
				pass
			PlayerCharacter.MovementMode.CROUCHING:
				pass
			PlayerCharacter.MovementMode.CRAWL:
				pass
		InputManager.player_character_input = true)
