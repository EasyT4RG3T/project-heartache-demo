class_name Screw3D
extends StaticBody3D


signal unscrewed


@onready var mesh_screw: MeshInstance3D = $MeshScrew
@onready var collision_screw: CollisionShape3D = $CollisionScrew


const UNSCREW_01 = preload("uid://bhc738xt12pgf")
const UNSCREW_02 = preload("uid://d0hsthy6er15h")
const UNSCREW_03 = preload("uid://dxgijeyp7oqep")
var unscrew_sounds: Array = [UNSCREW_01, UNSCREW_02, UNSCREW_03]


var interactable: Interactable = Interactable.new()

var unscrew_time: float = 3.0
var unscrew_tween: Tween


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.hold = true
	interactable.hold_time = 0.05
	interactable.show_type = Interactable.ShowType.HOLD
	
	interactable.started_looking.connect(func(player: PlayerCharacter):
		if player.inventory.screwdriver.disabled:
			interactable.semi_active = true
		else:
			interactable.semi_active = false)
	
	interactable.started_interacting.connect(func(player: PlayerCharacter):
		if interactable.semi_active:
			player.add_thought("I need a screwdriver")
		else:
			player.inventory.screwdriver.start_unscrewing(mesh_screw.global_transform, self))
	
	interactable.stopped_interacting.connect(func(player: PlayerCharacter):
		if !interactable.semi_active:
			player.inventory.screwdriver.stop_unscrewing())


func start_unscrewing(player: PlayerCharacter) -> void:
	if !unscrew_tween:
		unscrew_tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		unscrew_tween.tween_property(mesh_screw, "rotation:y", PI*3, unscrew_time)
		unscrew_tween.parallel().tween_property(mesh_screw, "position:y", 0.02, unscrew_time)
		unscrew_tween.parallel().tween_property(collision_screw, "position:y", 0.02, unscrew_time)
		unscrew_tween.pause()
		unscrew_tween.finished.connect(func():
			interactable.active = false
			player.interactable = null
			unscrewed.emit()
			var pak_rigid_screw: PackedScene = load("uid://mjprxjwm2yl0")
			var rigid_screw: Node3D = pak_rigid_screw.instantiate()
			add_sibling(rigid_screw)
			rigid_screw.global_transform = mesh_screw.global_transform
			player.inventory.screwdriver.stop_unscrewing()
			queue_free())
	
	var audio: AudioStreamPlayer3D = AudioManager.play_sound_at("SFX", unscrew_sounds.pick_random(), global_position)
	audio.seek(unscrew_tween.get_total_elapsed_time())
	
	while interactable.is_interacting:
		await get_tree().physics_frame
		unscrew_tween.custom_step(get_tree().root.get_physics_process_delta_time())
		player.inventory.screwdriver.global_transform = mesh_screw.global_transform
	
	if audio:
		audio.finished.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if unscrew_tween:
			unscrew_tween.kill()


func save() -> Dictionary:
	var file: Dictionary = {
		"mesh_transform": mesh_screw.global_transform,
		"collision_transform": collision_screw.global_transform,
		"unscrew_time": unscrew_time,
	}
	
	return file


func load_save(file: Dictionary) -> void:
	unscrew_time = file["unscrew_time"]
	mesh_screw.global_transform = file["mesh_transform"]
	collision_screw.global_transform = file["collision_transform"]
