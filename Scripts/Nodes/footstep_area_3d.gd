class_name FootstepArea3D
extends Area3D


@export var mod: FootstepsResource.Mod


func _ready() -> void:
	monitorable = false
	collision_layer = 0
	collision_mask = 8
	
	body_entered.connect(_set_footstep)
	body_exited.connect(_unset_footstep)


func _set_footstep(body: PlayerCharacter) -> void:
	if body.current_footsteps_mod.has(mod): return
	body.current_footsteps_mod.append(mod)


func _unset_footstep(body: PlayerCharacter) -> void:
	body.current_footsteps_mod.erase(mod)
