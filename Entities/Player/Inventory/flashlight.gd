class_name Flashlight
extends Node3D


@onready var light: SpotLight3D = %Light
const FLASHLIGHT_CLICKING_OFF = preload("uid://b4ib7bjp8jbuf")
const FLASHLIGHT_CLICKING_ON = preload("uid://cjv3tpi7ahesh")


var cooldown: Timer

 
var disabled: bool = true:
	set(value):
		disabled = value
		if value == true:
			light.hide()
			if journal_entry:
				journal_entry.queue_free()
		else:
			journal_entry = GameManager.journal.add("Flashlight", "[color=red][F][/color] Flashlight")
var journal_entry: RichTextLabel

var batteries: Array[float] = []
var current_battery: float = 0.0


func _ready() -> void:
	if disabled:
		light.hide()
	
	cooldown = Timer.new()
	cooldown.one_shot = true
	add_child(cooldown)


func switch() -> void:
	if disabled:
		return
	
	if cooldown.time_left:
		return
	
	if light.visible:
		AudioManager.play_sound_at("SFX", FLASHLIGHT_CLICKING_OFF, global_position)
		await get_tree().create_timer(0.1).timeout
		turn_off()
	else:
		AudioManager.play_sound_at("SFX", FLASHLIGHT_CLICKING_ON, global_position)
		await get_tree().create_timer(0.1).timeout
		turn_on()
	
	cooldown.start(0.2)


func turn_on() -> void:
	if disabled:
		return
	light.show()


func turn_off() -> void:
	if disabled:
		return
	light.hide()
