@tool
extends EditorScript


var scenes: PackedStringArray = []
var output: String = ""


func _run() -> void:
	
	## SELECT INPUT SCENES
	
	var scenes_select_dialog = FileDialog.new()
	scenes_select_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	scenes_select_dialog.filters = ["*.glb"]
	scenes_select_dialog.display_mode = FileDialog.DISPLAY_LIST
	
	EditorInterface.get_base_control().add_child(scenes_select_dialog)
	
	scenes_select_dialog.popup_centered()
	
	scenes_select_dialog.files_selected.connect(func(paths: PackedStringArray):
		scenes = paths.duplicate())
	
	await scenes_select_dialog.get_ok_button().pressed
	
	print(scenes)
	
	scenes_select_dialog.queue_free()
	
	## SELECT OUTPUT PATH
	
	var output_select_dialog = FileDialog.new()
	output_select_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	output_select_dialog.display_mode = FileDialog.DISPLAY_LIST
	
	EditorInterface.get_base_control().add_child(output_select_dialog)
	
	output_select_dialog.popup_centered()
	
	output_select_dialog.dir_selected.connect(func(path: String):
		output = path)
	
	await output_select_dialog.get_ok_button().pressed
	
	print(output)
	
	output_select_dialog.queue_free()
	
	
