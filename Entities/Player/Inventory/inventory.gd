class_name Inventory
extends Node3D


var p: PlayerCharacter


@onready var flashlight: Flashlight = %Flashlight
@onready var screwdriver: Node3D = %Screwdriver
@onready var hand: Node3D = %Hand
@onready var journal: Node3D = %Journal
@onready var glock_19: Node3D = %Glock19
var glock_19_disabled: bool = true:
	set(value):
		glock_19_disabled = value
		if value and current_slot == Slots.GLOCK_19:
			current_slot = Slots.NONE


var slot_timer: Timer = Timer.new()


enum Slots { NONE, INVENTORY, GLOCK_19 }
var current_slot: Slots:
	set(value):
		p.inventory_input = true
		match value:
			Slots.NONE:
				p.inventory_input = false
			Slots.INVENTORY:
				journal.show()
				journal.animation_player.play("Open")
				slot_timer.start(0.3)
			Slots.GLOCK_19:
				glock_19.process_mode = Node.PROCESS_MODE_INHERIT
				glock_19.show()
				glock_19.reset_physics_interpolation()
				glock_19.animation_player.play("PullOut")
		match current_slot:
			Slots.NONE:
				pass
			Slots.INVENTORY:
				if value == Slots.NONE:
					journal.animation_player.play("Close")
					slot_timer.start(0.3)
					slot_timer.timeout.connect(func():
						journal.hide(),
						CONNECT_ONE_SHOT)
				else:
					journal.hide()
			Slots.GLOCK_19:
				if glock_19.aiming:
					glock_19.aiming = false
				if value == Slots.NONE:
					glock_19.animation_player.play("Holster")
					slot_timer.start(0.1)
					slot_timer.timeout.connect(func():
						journal.hide()
						glock_19.process_mode = Node.PROCESS_MODE_DISABLED,
						CONNECT_ONE_SHOT)
				else:
					glock_19.hide()
					glock_19.process_mode = Node.PROCESS_MODE_DISABLED
		
		current_slot = value


func _ready() -> void:
	add_child(slot_timer)
	slot_timer.one_shot = true


func take_input(event: InputEvent) -> void:
	match current_slot:
		Slots.GLOCK_19:
			glock_19.take_input(event)


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
	
	hand.global_transform = p.main_camera.global_transform


func switch_slot(slot: Slots) -> void:
	if slot_timer.time_left > 0: return
	
	match slot:
		Slots.NONE:
			current_slot = Slots.NONE
		Slots.INVENTORY:
			if current_slot == Slots.INVENTORY:
				current_slot = Slots.NONE
			else:
				current_slot = Slots.INVENTORY
		Slots.GLOCK_19:
			if glock_19_disabled: return
			if current_slot == Slots.GLOCK_19:
				current_slot = Slots.NONE
			else:
				current_slot = Slots.GLOCK_19


func save() -> Dictionary:
	var file: Dictionary = {}
	
	file["flashlight"] = {
		"disabled": flashlight.disabled,
		"visible": flashlight.light.visible,
	}
	file["screwdriver"] = {
		"disabled": screwdriver.disabled,
	}
	
	file["current_slot"] = current_slot
	
	file["glock_19"] = glock_19.save()
	file["glock_19_disabled"] = glock_19_disabled
	
	return file


func load_save(file: Dictionary) -> void:
	flashlight.disabled = file["flashlight"]["disabled"]
	flashlight.light.visible = file["flashlight"]["visible"]
	
	screwdriver.disabled = file["screwdriver"]["disabled"]
	
	current_slot = file["current_slot"]
	
	glock_19.load_save(file["glock_19"])
	glock_19_disabled = file["glock_19_disabled"]
