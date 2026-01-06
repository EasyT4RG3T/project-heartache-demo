class_name PlayerHUD
extends Control


@onready var thought_label: RichTextLabel = %ThoughtLabel


@export var hud_color_primary: Color = Color.GRAY
@export var hud_color_secondary: Color = Color.DIM_GRAY
@export var hud_color_accent: Color = Color.LIGHT_GRAY
@export var hud_opacity_active: float = 0.8
@export var hud_opacity_inactive: float = 0.0
@export var thought_text_offset: float = 10.0
@export var thought_text_size: float = 16

var hud_size: float = 1.0

var default_crosshair_radius: float = 2.0:
	set(value):
		default_crosshair_radius = value
		apply_settings()
var crosshair_radius: float = default_crosshair_radius
var crosshair_opacity: float = hud_opacity_inactive
var vault_width: float = 3.0
var vault_opacity: float = hud_opacity_inactive
var interact_radius: float = default_crosshair_radius
var interact_width: float = 2.0
var interact_opacity: float = hud_opacity_inactive

const default_tween_time: float = 0.2
var crosshair_tween: Tween
var active: bool = false:
	set(value):
		if active == value: return
		active = value
		
		if crosshair_tween:
			crosshair_tween.kill()
		
		crosshair_tween = create_tween().set_ease(Tween.EASE_IN_OUT).\
			set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_parallel(true)
		
		var target_radius = default_crosshair_radius * 1.5 if value else default_crosshair_radius
		var target_opacity = hud_opacity_active if value else hud_opacity_inactive
		
		crosshair_tween.tween_property(self, "crosshair_radius", target_radius * hud_size, default_tween_time)
		crosshair_tween.tween_property(self, "crosshair_opacity", target_opacity, default_tween_time)
		
		while crosshair_tween.is_running():
			await get_tree().process_frame
			queue_redraw()

var interact_tween: Tween
var can_tap: bool = false:
	set(value):
		if can_tap == value: return
		can_tap = value
		interact_radius = 5 * hud_size
		
		var target_opacity = hud_opacity_active if value else 0.0
		
		if interact_tween:
			interact_tween.kill()
		
		interact_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		interact_tween.tween_property(self, "interact_opacity", target_opacity, default_tween_time)
		
		while can_tap:
			await get_tree().process_frame
			if interact_radius > 0:
				interact_radius -= get_process_delta_time() * 10 * hud_size
			else:
				interact_radius = 5 * hud_size
			queue_redraw()

var can_hold: bool = false:
	set(value):
		if can_hold == value: return
		can_hold = value
		var pulse_dir = false
		interact_radius = 5 * hud_size
		
		var target_opacity = hud_opacity_active if value else 0.0
		
		if interact_tween:
			interact_tween.kill()
		
		interact_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		interact_tween.tween_property(self, "interact_opacity", target_opacity, default_tween_time)
		
		while can_hold:
			await get_tree().process_frame
			if pulse_dir:
				interact_radius -= get_process_delta_time() * 5 * hud_size
			else:
				interact_radius += get_process_delta_time() * 5 * hud_size
			if interact_radius <= 0:
				pulse_dir = false
			elif interact_radius >= 5 * hud_size:
				pulse_dir = true
			queue_redraw()

var vault_tween: Tween
var vault: bool:
	set(value):
		if vault == value: return
		vault = value
		
		if vault_tween:
			vault_tween.kill()
		
		vault_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		var target_opacity = hud_opacity_active if value else 0.0
		
		vault_tween.tween_property(self, "vault_opacity", target_opacity, default_tween_time * 0.5)
		
		while vault_tween.is_running():
			queue_redraw()
			await get_tree().process_frame

var thought_tween: Tween
var current_thougt_story: bool = false
var thought_timer: Timer = Timer.new()


func _ready() -> void:
	apply_settings()
	thought_label.modulate.a = 0.0
	add_child(thought_timer)
	thought_timer.one_shot = true
	thought_timer.timeout.connect(_hide_thought)


func _draw() -> void:
	var center = get_viewport().get_visible_rect().size / 2
	
	_draw_crosshair(center)
	_draw_vault(center)
	_draw_interact(center)


func _draw_crosshair(center: Vector2) -> void:
	draw_circle(center, crosshair_radius + 1, hud_color_secondary * Color(1, 1, 1, crosshair_opacity))
	draw_circle(center, crosshair_radius, hud_color_primary * Color(1, 1, 1, crosshair_opacity))


func _draw_vault(center: Vector2) -> void:
	draw_arc(
		center,
		crosshair_radius + vault_width * hud_size * 1.5,
		-PI * 0.7,
		-PI * 0.3,
		int(6 * hud_size),
		hud_color_primary * Color(1, 1, 1, vault_opacity),
		vault_width * hud_size
		)


func _draw_interact(center: Vector2) -> void:
	draw_arc(
		center,
		crosshair_radius + interact_radius + interact_width * hud_size,
		0,
		TAU,
		int(12 * hud_size),
		hud_color_secondary * Color(1, 1, 1, interact_opacity),
		interact_width * hud_size
	)


func display_thought(thought: String, story: bool, time: float = 2.0) -> void:
	if current_thougt_story and !story:
		return
	
	if thought_tween:
		thought_tween.kill()
	
	if !thought_timer.is_stopped():
		thought_timer.stop()
	
	thought_label.text = thought
	thought_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	
	thought_tween.tween_property(thought_label, "modulate:a", hud_opacity_active, default_tween_time)
	thought_tween.finished.connect(func():
		thought_timer.start(time))


func _hide_thought() -> void:
	current_thougt_story = false
	if thought_tween:
		thought_tween.kill()
	
	thought_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	
	thought_tween.tween_property(thought_label, "modulate:a", 0.0, default_tween_time)


func apply_settings() -> void:
	hud_size = SaverLoader.settings.hud_size
	queue_redraw()
	thought_label.offset_top = default_crosshair_radius + thought_text_offset * hud_size
	var font_size = int(thought_text_size * hud_size)
	thought_label.add_theme_font_size_override("normal_font_size", font_size)
	thought_label.add_theme_font_size_override("bold_font_size", font_size)
	thought_label.add_theme_font_size_override("italics_font_size", font_size)
	thought_label.add_theme_font_size_override("bold_italics_font_size", font_size)
	thought_label.add_theme_font_size_override("mono_font_size", font_size)
