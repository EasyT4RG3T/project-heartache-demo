class_name Glock19
extends Node3D


signal shot


@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var bullet_barrel: MeshInstance3D = %BulletBarrel
@onready var bullet_chamber: MeshInstance3D = %BulletChamber
@onready var aim_marker: Marker3D = $GlockHandle/AimMarker

@onready var rigid_glock_bullet_1: DynamicRigidBody3D = %RigidGlockBullet1
@onready var rigid_glock_bullet_2: DynamicRigidBody3D = %RigidGlockBullet2
@onready var rigid_glock_bullet_3: DynamicRigidBody3D = %RigidGlockBullet3

var current_casing: int = 1:
	set(value):
		if value > 3:
			value = 1
		current_casing = value

@onready var flare: SpotLight3D = %Flare

@onready var bullet_1: MeshInstance3D = %Bullet1
@onready var bullet_2: MeshInstance3D = %Bullet2
@onready var bullet_3: MeshInstance3D = %Bullet3
@onready var bullet_4: MeshInstance3D = %Bullet4
@onready var bullet_5: MeshInstance3D = %Bullet5
@onready var bullet_6: MeshInstance3D = %Bullet6
@onready var bullet_7: MeshInstance3D = %Bullet7
@onready var bullet_8: MeshInstance3D = %Bullet8
@onready var bullet_9: MeshInstance3D = %Bullet9
@onready var bullet_10: MeshInstance3D = %Bullet10
@onready var bullet_11: MeshInstance3D = %Bullet11
@onready var bullet_12: MeshInstance3D = %Bullet12
@onready var bullet_13: MeshInstance3D = %Bullet13
@onready var bullet_14: MeshInstance3D = %Bullet14
@onready var bullet_15: MeshInstance3D = %Bullet15

const COCK = preload("uid://bvrj61pf3dj1s")
const COCK_OUT = preload("uid://d0bsna2750dck")
const DRY_FIRE = preload("uid://s4gwm0jfr8rr")
const HOLSTER_IN = preload("uid://xqrosyd648tr")
const HOLSTER_OUT = preload("uid://p5g372uxvh6y")
const MAG_IN = preload("uid://dbrdwfm01nvrv")
const MAG_OUT = preload("uid://j6xuai85bdeo")
const SHOT_01 = preload("uid://cm4rowsc5gaci")
const SHOT_02 = preload("uid://dsq4xd80twb2l")
const SHOT_03 = preload("uid://d3nijuhh3000o")

const BULLET_HOLE = preload("uid://jx71inl833iq")

var offset: Vector3 = Vector3(0.09, -0.14, -0.15)
var aim_offset: Vector3 = Vector3(0, -0.115, -0.15)
var wanted_offset: Vector3 = Vector3.ZERO

var disabled: bool = true:
	set(value):
		disabled = value 
		if value:
			if GameManager.player_character.inventory.current_slot == Inventory.Slots.GLOCK_19:
				GameManager.player_character.inventory.current_slot = Inventory.Slots.NONE
			if journal_entry:
				journal_entry.queue_free()
		else:
			journal_entry = GameManager.journal.add("Glock19", "[color=red][1][/color] Glock19")
			if mags > 1:
				journal_entry.text = "[color=red][1][/color] Glock19 (" + str(mags) + " mags)"
			elif mags == 1:
				journal_entry.text = "[color=red][1][/color] Glock19 (one mag)"
			else:
				journal_entry.text = "[color=red][1][/color] Glock19"

var aiming: bool = false

var recoil: Vector2 = Vector2.ZERO

var ammo: int = 16:
	set(value):
		value = clampi(value, 0, 16)
		
		if value == 0:
			for i in 15:
				get("bullet_" + str(i + 1)).hide()
			bullet_barrel.hide()
			bullet_chamber.hide()
		elif value < ammo:
			if get("bullet_" + str(value)):
				get("bullet_" + str(value)).hide()
		else:
			for i in value:
				if get("bullet_" + str(i)):
					get("bullet_" + str(i)).show()
			bullet_barrel.show()
			bullet_chamber.show()
		
		ammo = value

var mags: int = 3:
	set(value):
		mags = value
		if mags > 1:
			journal_entry.text = "[color=red][1][/color] Glock19 (" + str(mags) + " mags)"
		elif mags == 1:
			journal_entry.text = "[color=red][1][/color] Glock19 (one mag)"
		else:
			journal_entry.text = "[color=red][1][/color] Glock19"

var can_shoot: bool = true

var direct_space_state: PhysicsDirectSpaceState3D
var aim_ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
var shot_ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()

var journal_entry: RichTextLabel


func take_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_main"):
		shoot()
	
	if event.is_action_pressed("use_second"):
		aim()
	
	if event.is_action_released("use_second"):
		if SaverLoader.settings.hold_aim:
			stop_aim()
	
	if event.is_action_pressed("reload"):
		reload()
	
	if event.is_action_pressed("use_third"):
		mag_check()


func _ready() -> void:
	hide()
	flare.hide()
	
	direct_space_state = get_world_3d().direct_space_state
	
	for i in 3:
		get("rigid_glock_bullet_" + str(i + 1)).hide()
		get("rigid_glock_bullet_" + str(i + 1)).process_mode = Node.PROCESS_MODE_DISABLED
	
	visibility_changed.connect(func():
		if visible:
			AudioManager.play_sound("SFX", HOLSTER_OUT)
		else:
			AudioManager.play_sound("SFX", HOLSTER_IN))
	
	aim_ray_query.collision_mask = 4103
	shot_ray_query.collision_mask = 7


func _physics_process(delta: float) -> void:
	recoil *= 0.5
	for i in 3:
		if !get("rigid_glock_bullet_" + str(i + 1)).visible: continue
		if (get("rigid_glock_bullet_" + str(i + 1)).global_position - global_position).length() > 5.0:
			get("rigid_glock_bullet_" + str(i + 1)).hide()
			get("rigid_glock_bullet_" + str(i + 1)).process_mode = Node.PROCESS_MODE_DISABLED
	
	aim_ray_query.from = aim_marker.global_position
	aim_ray_query.to = aim_ray_query.from - aim_marker.global_basis.z * 50
	
	var aim_ray_result: Dictionary = direct_space_state.intersect_ray(aim_ray_query)
	
	if aim_ray_result:
		var aim_collider: Node3D = aim_ray_result["collider"]
		if aim_collider.collision_layer >= 4096 and aim_collider.collision_layer < 8192:
			can_shoot = false
		else:
			can_shoot = true
	
	rotation.x = lerp_angle(
		rotation.x,
		0 + recoil.y,
		delta * 5
	)
	rotation.y = lerp_angle(
		rotation.y,
		0 + recoil.x,
		delta * 5
	)
	
	if aiming:
		wanted_offset = wanted_offset.lerp(aim_offset, delta * 10)
	else:
		wanted_offset = wanted_offset.lerp(offset, delta * 10)
	
	position = wanted_offset


func shoot() -> void:
	if animation_player.is_playing(): return
	if !can_shoot: return
	if ammo <= 0:
		AudioManager.play_sound("SFX", DRY_FIRE, 0, randf_range(0.8, 1.2))
		return
	
	shot.emit()
	
	AudioManager.play_sound("SFX", [SHOT_01, SHOT_02, SHOT_03].pick_random(), 5, randf_range(0.89, 0.91))
	
	recoil.y += randf_range(2.5, 3.5)
	recoil.x += randf_range(-1, 1)
	if ammo == 1:
		animation_player.play("ShootLast")
	else:
		animation_player.play("Shoot")
	ammo -= 1
	
	shot_ray_query.from = aim_marker.global_position
	shot_ray_query.to = shot_ray_query.from - aim_marker.global_basis.z * 50
	
	var shot_ray_result: Dictionary = direct_space_state.intersect_ray(shot_ray_query)
	
	if shot_ray_result:
		var shot_collider: Node3D = shot_ray_result["collider"]
		var shot_position: Vector3 = shot_ray_result["position"]
		var shot_normal: Vector3 = shot_ray_result["normal"]
	
		if shot_collider is RigidBody3D:
			shot_collider.apply_impulse(-global_basis.z * 5, shot_position)
	
		if shot_normal != Vector3.ZERO:
			var bullet_hole: Decal = BULLET_HOLE.instantiate()
			shot_collider.add_child(bullet_hole)
			bullet_hole.global_position = shot_position
			bullet_hole.look_at(shot_position + shot_normal, Vector3.UP)
			bullet_hole.rotate_object_local(Vector3.LEFT, PI / 2)
	
	_casing()
	
	flare.show()
	await get_tree().physics_frame
	await get_tree().physics_frame
	flare.hide()


func aim() -> void:
	if animation_player.is_playing(): return
	
	if aiming and !SaverLoader.settings.hold_aim:
		stop_aim()
	else:
		aiming = true


func stop_aim() -> void:
	aiming = false


func reload() -> void:
	if animation_player.is_playing(): return
	if ammo >= 16:
		DialogueManager.say("It's full", 3)
		return
	
	if mags <= 0:
		DialogueManager.say("I need to find ammo", 3)
		return
	
	mags -= 1
	
	if mags > 1:
		DialogueManager.say(str(mags) + " mags left", 3)
		journal_entry.text = "[color=red][1][/color] Glock19 (" + str(mags) + " mags)"
	elif mags == 1:
		DialogueManager.say("one mag left", 3)
		journal_entry.text = "[color=red][1][/color] Glock19 (one mag)"
	else:
		DialogueManager.say("that's the last mag", 3)
		journal_entry.text = "[color=red][1][/color] Glock19"
	
	if ammo > 0:
		animation_player.play("Reload")
	else:
		animation_player.play("ReloadEmpty")


func mag_check() -> void:
	if animation_player.is_playing(): return
	if ammo <= 0: return
	
	if ammo > 4:
		DialogueManager.say(str(ammo) + " bullets left", 3)
		
		if aiming:
			animation_player.play("MagCheck_Aim")
		else:
			animation_player.play("MagCheck")
	elif ammo > 1:
		DialogueManager.say("only " + str(ammo) + " bullets left", 3)
		
		if aiming:
			animation_player.play("MagCheckLow_Aim")
		else:
			animation_player.play("MagCheckLow")
	else:
		DialogueManager.say("last bullet", 3)
		if aiming:
			animation_player.play("MagCheckLast_Aim")
		else:
			animation_player.play("MagCheckLast")


func refil_ammo(amount: int) -> void:
	ammo = amount


func _casing() -> void:
	get("rigid_glock_bullet_" + str(current_casing)).global_transform = global_transform
	get("rigid_glock_bullet_" + str(current_casing)).global_position += Vector3(0, 0.11, -0.018)
	get("rigid_glock_bullet_" + str(current_casing)).linear_velocity = Vector3.ZERO
	get("rigid_glock_bullet_" + str(current_casing)).angular_velocity = Vector3.ZERO
	get("rigid_glock_bullet_" + str(current_casing)).show()
	get("rigid_glock_bullet_" + str(current_casing)).process_mode = Node.PROCESS_MODE_INHERIT
	get("rigid_glock_bullet_" + str(current_casing)).apply_impulse(global_basis.y * 0.1 + global_basis.x * 0.2, Vector3(0, randf_range(-0.001, 0.001), randf_range(-0.001, 0.001)))
	current_casing += 1


func play_sound(sound: int) -> void:
	match sound:
		1:
			AudioManager.play_sound("SFX", COCK)
		2:
			AudioManager.play_sound("SFX", COCK_OUT)
		3:
			AudioManager.play_sound("SFX", DRY_FIRE)
		4:
			AudioManager.play_sound("SFX", HOLSTER_IN, 10)
		5:
			AudioManager.play_sound("SFX", HOLSTER_OUT, 10)
		6:
			AudioManager.play_sound("SFX", MAG_IN)
		7:
			AudioManager.play_sound("SFX", MAG_OUT)
		8:
			AudioManager.play_sound("SFX", SHOT_01)
		9:
			AudioManager.play_sound("SFX", SHOT_02)
		10:
			AudioManager.play_sound("SFX", SHOT_03)


func save() -> Dictionary:
	var file: Dictionary = {}
	
	file["disabled"] = disabled
	file["aiming"] = aiming
	file["ammo"] = ammo
	file["mags"] = mags
	file["can_shoot"] = can_shoot
	
	return file


func load_save(file: Dictionary) -> void:
	disabled = file["disabled"]
	aiming = file["aiming"]
	ammo = 0
	ammo = file["ammo"]
	if ammo == 0:
		animation_player.play("ShootLast")
	mags = file["mags"]
	can_shoot = file["can_shoot"]
