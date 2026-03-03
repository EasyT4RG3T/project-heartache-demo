@tool
class_name DynamicSpotLight3D
extends SpotLight3D


var out_of_area: bool = false:
	set(value):
		out_of_area = value
		if value:
			hide()
		elif blinking > 1:
			show()

@export var cull_distance: float = 10.0
@export var area: Area3D

@export var blink_out: float = 0.0
@export var blink_out_rand: float = 0.0
@export var blink_in: float = 0.1
@export var blink_in_rand: float = 0.0

var blink_timer: Timer
var blinking: int = 0

@export_tool_button("Set up") var set_up: Callable = func():
	if Engine.is_editor_hint():
		spot_angle = 80
		light_bake_mode = Light3D.BAKE_DISABLED
		shadow_enabled = true
		shadow_bias = 0.01
		shadow_blur = 1.0
		distance_fade_enabled = true
		distance_fade_begin = 5.0
		distance_fade_shadow = 10.0
		distance_fade_length = 10.0
		add_to_group("DynamicLights")


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	add_to_group("DynamicLights")
	if area:
		area.collision_layer = 8
		area.collision_mask = 8
		area.monitoring = true
		area.monitorable = false
		area.body_entered.connect(func(_body: Node3D):
			out_of_area = false)
		area.body_exited.connect(func(_body: Node3D):
			out_of_area = true)
		if !area.has_overlapping_bodies():
			out_of_area = true
	
	if blink_out > 0.0:
		blink()


func blink():
	if !blink_timer:
		blink_timer = Timer.new()
		add_child(blink_timer)
	
	if visible:
		_blink_out()
	else:
		_blink_in()


func blink_stop(on: bool):
	blinking = 0
	if blink_timer:
		blink_timer.stop()
		blink_timer.queue_free()
	if out_of_area: return
	if on:
		show()
	else:
		hide()


func _blink_in() -> void:
	if !out_of_area:
		show()
	blinking = 1
	var blink_out_time = blink_out
	if blink_out_rand > 0.0:
		blink_out_time = randf_range(blink_out, blink_out_rand)
	blink_timer.start(blink_out_time)
	await blink_timer.timeout
	_blink_out()


func _blink_out() -> void:
	if !out_of_area:
		hide()
	blinking = -1
	var blink_in_time = blink_in
	if blink_in_rand > 0.0:
		blink_in_time = randf_range(blink_in, blink_in_rand)
	blink_timer.start(blink_in_time)
	await blink_timer.timeout
	_blink_in()


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if !GameManager.player_character: return
	
	if out_of_area: return
	
	var vector: Vector3 = global_position - GameManager.player_character.global_position
	var distance: float = vector.length()
	
	if distance > cull_distance:
		var dot: float = vector.normalized().dot(GameManager.player_character.head.basis.z)
		if visible and dot > 0:
			hide()
		elif !visible and dot < 0 and blinking >= 0:
			show()
	elif !visible and blinking >= 0:
		show()
