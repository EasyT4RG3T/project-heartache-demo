extends Node


@onready var vbox: VBoxContainer = %VBoxContainer
@onready var continue_ui: TextureRect = %ContinueUI
var continue_ui_modulate: bool = false

const ALKHEMIKAL = "uid://ec2tuv0fro0y"
const BELANIDI_SERIF_REGULAR = "uid://etpshq7cu6we"
const BIRCH_LEAF = "uid://blrxf3yqmo8ap"
const BONEFISH = "uid://vq4sgj0ev538"
const COMICORO = "uid://deuuqjpwmbb7o"
const DOUBLE_HOMICIDE = "uid://ct8ny0u7r1u7r"
const GRAPE_SODA = "uid://duvqh2fmca6yj"
const NOTEPEN = "uid://xoru8jjgd8sd"
const PEANUT_MONEY = "uid://bvw45gfb5pqv7"
const RUNESCAPE_UF = "uid://b4j2uqpcfscx"

var default_font: String = RUNESCAPE_UF
var default_font_size: int = 40


var dialogues: Dictionary[RichTextLabel, SceneTreeTimer] = {}


func _ready() -> void:
	continue_ui.hide()


func _physics_process(delta: float) -> void:
	if continue_ui_modulate:
		continue_ui.modulate.a -= delta * 0.5
		if continue_ui.modulate.a < 0.6:
			continue_ui_modulate = false
	else:
		continue_ui.modulate.a += delta * 0.5
		if continue_ui.modulate.a >= 1.0:
			continue_ui_modulate = true


func say(text: String, duration: float = 10) -> Dictionary:
	if dialogues.size() >= 3:
		var key: RichTextLabel = dialogues.keys()[dialogues.keys().size() - 1]
		if key:
			key.queue_free()
	
	var label: RichTextLabel = RichTextLabel.new()
	vbox.add_child(label)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.bbcode_enabled = true
	text = text.format({
		"alkhemikal": "font="+ALKHEMIKAL+"][font_size="+str(default_font_size),
		"belanidi": "font="+BELANIDI_SERIF_REGULAR+"][font_size="+str(default_font_size * 0.65),
		"birch": "font="+BIRCH_LEAF+"][font_size="+str(default_font_size),
		"bonefish": "font="+BONEFISH+"][font_size="+str(default_font_size),
		"comicoro": "font="+COMICORO+"][font_size="+str(default_font_size * 1.2),
		"homicide": "font="+DOUBLE_HOMICIDE+"][font_size="+str(default_font_size),
		"grape": "font="+GRAPE_SODA+"][font_size="+str(default_font_size),
		"notepen": "font="+NOTEPEN+"][font_size="+str(default_font_size),
		"peanut": "font="+PEANUT_MONEY+"][font_size="+str(default_font_size * 1.2),
		"rune": "font="+RUNESCAPE_UF+"][font_size="+str(default_font_size),
		
		"endfont": "/font_size][/font",
		
		"red": "color=red",
		"green": "color=green",
		"blue": "color=blue",
		"yellow": "color=yellow",
		"pink": "color=pink",
		"gray": "color=gray",
		"black": "color=black",
	})
	text = "[font="+default_font+"][font_size="+str(default_font_size)+"]" + text + "[/font_size][/font]"
	label.text = text
	label.fit_content = true
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var dialogue: Dictionary = {}
	if duration <= 0:
		dialogue[label] = null
		dialogues.assign(dialogue)
		return dialogue
	
	dialogue[label] = get_tree().create_timer(duration)
	dialogue[label].timeout.connect(func():
		if label:
			dialogues.erase(label)
			label.queue_free(), CONNECT_ONE_SHOT)
	
	dialogues.assign(dialogue)
	return dialogue


func remove(label: RichTextLabel) -> void:
	dialogues.erase(label)
	if label:
		label.queue_free()


func clear() -> void:
	continue_ui.hide()
	for label in dialogues:
		dialogues.erase(label)
		if label:
			label.queue_free()


func apply_settings() -> void:
	default_font_size = SaverLoader.settings.subtitles
	var size = 64 * SaverLoader.settings.hud_size
	continue_ui.custom_minimum_size = Vector2(size, size)
