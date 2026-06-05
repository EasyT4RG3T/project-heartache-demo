class_name Journal
extends Node3D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sub_viewport_container: SubViewportContainer = $JournalArmature/SubViewportContainer
@onready var items_container: VBoxContainer = $JournalArmature/SubViewportContainer/SubViewport/Control/ItemsContainer
@onready var items_rich_text_label: RichTextLabel = %ItemsRichTextLabel
@onready var quest_rich_text_label: RichTextLabel = %QuestRichTextLabel


func _ready() -> void:
	sub_viewport_container.visibility_layer = 0
	sub_viewport_container.hide()
	hide()
	visibility_changed.connect(func():
		if visible:
			sub_viewport_container.show()
		else:
			sub_viewport_container.hide())
	
	quest_rich_text_label.text = Game.story_description


func add(item: String, text: String) -> RichTextLabel:
	var dup = items_container.find_child(item, false, false)
	if dup:
		print("ERROR JOUNRAL DUPLICATE: " + dup)
		return
	
	var label = items_rich_text_label.duplicate()
	label.name = item
	label.text = text
	items_container.add_child(label)
	return label
