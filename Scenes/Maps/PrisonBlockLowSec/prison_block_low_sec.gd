extends Node3D


@onready var cutscenes: Cutscene = %Cutscenes

var reflection_update: Timer = Timer.new()

enum Event { INIT, SETUP, TRIGGER, DISABLE }

var key_event_happened: bool = false
var toilet_paper_event_happened: bool = false
var picture_event_happened: bool = false


func _ready() -> void:
	GameManager.GameFullyLoaded.connect(func():
		if GameManager.is_new_game:
			cutscenes.play("WakeUp")
			GameManager.is_new_game = false)
	AudioManager.play_ambient("uid://c1auf3n2ayc5b", -10.0, 1.0)
	
	add_child(reflection_update)
	var nudge: bool = false
	reflection_update.timeout.connect(func():
		if nudge:
			$Cell01/ReflectionProbe2.global_position.y += 0.0001
		else:
			$Cell01/ReflectionProbe2.global_position.y -= 0.0001
		reflection_update.start(0.5))
	reflection_update.start(0.5)


func first_setup() -> void:
	toilet_paper_event(Event.SETUP)
	picture_event(Event.SETUP)
	key_event(Event.INIT)


var cooldown: float = 0.0
func _physics_process(delta: float) -> void:
	cooldown += delta
	if cooldown < 0.1:
		return
	else:
		cooldown = 0.0
	if !$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D.out_of_area:
		if $SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D.disabled:
			$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D.disabled = false
		else:
			var rand: int = randi_range(1, 3)
			if rand == 3:
				$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D.disabled = true
	if !$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D2.out_of_area:
		if $SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D2.disabled:
			$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D2.disabled = false
		else:
			var rand: int = randi_range(1, 3)
			if rand == 3:
				$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D2.disabled = true
	if !$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D3.out_of_area:
		if $SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D3.disabled:
			$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D3.disabled = false
		else:
			var rand: int = randi_range(1, 3)
			if rand == 3:
				$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D3.disabled = true
	if !$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D4.out_of_area:
		if $SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D4.disabled:
			$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D4.disabled = false
		else:
			var rand: int = randi_range(1, 3)
			if rand == 3:
				$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D4.disabled = true
	if !$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D5.out_of_area:
		if $SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D5.disabled:
			$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D5.disabled = false
		else:
			var rand: int = randi_range(1, 3)
			if rand == 3:
				$SecurityCorridor/Lights/Dynamic/DynamicSpotLight3D5.disabled = true


func animation_signal(animation: String) -> void:
	match animation:
		"WakeUp01":
			AudioManager.play_uid_sound("SFX", "uid://brc4swaa4mfyk", 0.0, 1.0)
		"WakeUp02":
			pass
		"WakeUp03":
			AudioManager.play_uid_sound("SFX", "uid://lt1hxj2141l1", -4.0, 0.9)
		"WakeUp04":
			AudioManager.play_uid_sound("SFX", "uid://lt1hxj2141l1", -4.0, 0.85)
		"PictureInspect01":
			AudioManager.play_uid_sound("SFX", "uid://qh1cl6auhn2b", -5.0, 0.8)
		"PictureInspect02":
			pass
		"PictureInspect03":
			%PictureSpotLight.hide()
			AudioManager.play_uid_sound("SFX", "uid://bcaovrflj7lr2", -10.0, 0.8)
			key_event(Event.SETUP)
		"KeyPickUp01":
			%KeyHighlightSpot.out_of_area = true
		"KeyPickUp02":
			%KeyEvent.queue_free()
			%Cell01DoorHinge3D.force_open(1)


func toilet_paper_event(event: Event) -> void:
	match event:
		Event.SETUP:
			%ToiletPaperEventOnScreen.screen_entered_plus.connect(toilet_paper_event.bind(Event.TRIGGER))
		Event.TRIGGER:
			var look_cut: LookCutscene = LookCutscene.new()
			add_child(look_cut)
			look_cut.animation_finished.connect(func():
				toilet_paper_event_happened = true
				look_cut.queue_free(),
				CONNECT_ONE_SHOT)
			look_cut.look($Cell01/Assets/Static/StaticToilet01.global_position + Vector3(0, 0.5, -0.2), 0.2, 1.0)
			Game.character_say(PlayerHUD.Characters.PLAYER, "Dammit", 1.5)
			for child in %ToiletPaperEvent.get_children():
				if child is RigidBody3D:
					child.apply_impulse(Vector3(0, 0, 0.7))
			toilet_paper_event(Event.DISABLE)
		Event.DISABLE:
			%ToiletPaperEventOnScreen.disabled = true


func picture_event(event: Event) -> void:
	match event:
		Event.SETUP:
			%PictureSpotLight.hide()
			%PictureInteract.interacted.connect(func(_player: PlayerCharacter):
				picture_event(Event.TRIGGER))
		Event.TRIGGER:
			%PictureSpotLight.show()
			cutscenes.play("PictureInspect")
			cutscenes.animation_finished.connect(func(_anim_name: StringName):
				picture_event_happened = true, CONNECT_ONE_SHOT)
			picture_event(Event.DISABLE)
		Event.DISABLE:
			%PictureInteract.active = false


func key_event(event: Event) -> void:
	match event:
		Event.INIT:
			%KeyEvent.hide()
			%CellDoor01FlapHinge3D.open_progress = 0.0
		Event.SETUP:
			while !GameManager.player_character:
				await get_tree().process_frame
			%KeyEvent.show()
			
			%KeyInteract.interacted.connect(func(_player: PlayerCharacter):
				key_event(Event.TRIGGER),
				CONNECT_ONE_SHOT)
			GameManager.player_character.player_hud.add_dialogue(
				PlayerHUD.Characters.CUSTOM,
				"Wanna get out of here?",
				3.5
			)
			await get_tree().process_frame
			%CellDoor01FlapHinge3D.open_progress = -165.0
			await get_tree().create_timer(0.2).timeout
			if !%KeyEvent.visible:
				%KeyEvent.show()
			AudioManager.play_uid_sound_at("SFX" ,"uid://epskxdoj4off", Vector3(-0.9, 0.0, -2.0), 0.0, 1.5)
		Event.TRIGGER:
			key_event_happened = true
			cutscenes.play("KeyPickUp")


func save() -> Dictionary:
	var data: Dictionary = {
		"key_event_happened": key_event_happened,
		"toilet_paper_event_happened": toilet_paper_event_happened,
		"picture_event_happened": picture_event_happened,
	}
	return data


func load_save(data: Dictionary) -> void:
	key_event_happened = data["key_event_happened"]
	toilet_paper_event_happened = data["toilet_paper_event_happened"]
	if !toilet_paper_event_happened:
		toilet_paper_event(Event.SETUP)
	picture_event_happened = data["picture_event_happened"]
	if !picture_event_happened:
		picture_event(Event.SETUP)
	elif !key_event_happened:
		key_event(Event.SETUP)
