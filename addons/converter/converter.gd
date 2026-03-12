@tool
extends EditorPlugin


var converter_context_menu: ConverterContext


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	converter_context_menu = ConverterContext.new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, converter_context_menu)


func _exit_tree() -> void:
	remove_context_menu_plugin(converter_context_menu)
