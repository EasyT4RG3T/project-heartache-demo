class_name Inventory
extends Node3D


var p: PlayerCharacter


@onready var flashlight: Flashlight = %Flashlight
@onready var screwdriver: Node3D = %Screwdriver
@onready var hand: Node3D = %Hand
@onready var glock_19: Node3D = %Glock19


var hand_offset: Vector3 = Vector3(0.09, -0.14, -0.15)
var hand_aim_offset: Vector3 = Vector3(0, -0.115, -0.15)
var wanted_hand_offset: Vector3 = Vector3.ZERO


func _ready() -> void:
	pass


func take_input(event: InputEvent) -> void:
	if glock_19.enabled:
		_glock_19_input(event)


func _glock_19_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_main"):
		glock_19.shoot()
	
	if event.is_action_pressed("use_second"):
		glock_19.aim()
	
	if event.is_action_released("use_second"):
		if SaverLoader.settings.hold_aim:
			glock_19.stop_aim()
	
	if event.is_action_pressed("reload"):
		glock_19.reload()
	
	if event.is_action_pressed("use_third"):
		glock_19.mag_check()


func _physics_process(delta: float) -> void:
	flashlight.global_position = p.head.global_position - p.head.basis.y * 0.2 - p.head.basis.x * 0.1
	
	flashlight.global_rotation.x = lerpf(
		flashlight.global_rotation.x,
		p.head.global_rotation.x,
		delta * 20
	)
	flashlight.global_rotation.y = lerp_angle(
		flashlight.global_rotation.y,
		p.head.global_rotation.y,
		delta * 20
	)
	
	if glock_19.aiming:
		wanted_hand_offset = wanted_hand_offset.lerp(hand_aim_offset, delta * 10)
	else:
		wanted_hand_offset = wanted_hand_offset.lerp(hand_offset, delta * 10)
	
	var wanted_hand_position = p.main_camera.global_position
	wanted_hand_position += p.main_camera.global_basis.x * wanted_hand_offset.x
	wanted_hand_position += p.main_camera.global_basis.y * wanted_hand_offset.y
	wanted_hand_position += p.main_camera.global_basis.z * wanted_hand_offset.z
	
	hand.global_position = wanted_hand_position


func switch_clear() -> void:
	glock_19.enabled = false
	p.inventory_input = false


func switch_glock() -> void:
	if glock_19.enabled:
		glock_19.enabled = false
		p.inventory_input = false
	else:
		glock_19.enabled = true
		p.inventory_input = true
		glock_19.reset_physics_interpolation()


func save() -> Dictionary:
	var file: Dictionary = {}
	
	file["flashlight"] = {
		"disabled": flashlight.disabled,
		"visible": flashlight.light.visible,
	}
	file["screwdriver"] = {
		"disabled": screwdriver.disabled,
	}
	
	return file


func load_save(file: Dictionary) -> void:
	flashlight.disabled = file["flashlight"]["disabled"]
	flashlight.light.visible = file["flashlight"]["visible"]
	
	screwdriver.disabled = file["screwdriver"]["disabled"]
