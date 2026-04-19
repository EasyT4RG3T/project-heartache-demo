extends Node


@onready var vbox: VBoxContainer = %VBoxContainer
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


func say(text: String) -> void:
	var label: RichTextLabel = RichTextLabel.new()
	vbox.add_child(label)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.bbcode_enabled = true
	text = text.format({
		"alkhemikal": ALKHEMIKAL,
		"belanidi": BELANIDI_SERIF_REGULAR,
		"birch": BIRCH_LEAF,
		"bonefish": BONEFISH,
		"comicoro": COMICORO,
		"homicide": DOUBLE_HOMICIDE,
		"grape": GRAPE_SODA,
		"notepen": NOTEPEN,
		"peanut": PEANUT_MONEY,
		"rune": RUNESCAPE_UF,
	})
	text = "[font="+default_font+"][font_size="+str(default_font_size)+"]" + text + "[/font_size][/font]"
	label.text = text
	label.fit_content = true
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	await get_tree().create_timer(10).timeout
	label.queue_free()


func apply_settings() -> void:
	default_font_size = SaverLoader.settings.subtitles
