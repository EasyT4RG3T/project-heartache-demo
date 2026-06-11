extends Node3D


var faze1_happened: bool = false:
	set(value):
		faze1_happened = value
		if value:
			for child in get_children():
				if child.has_method("faze1"):
					child.faze1()
var faze2_happened: bool = false:
	set(value):
		faze2_happened = value
		if value:
			for child in get_children():
				if child.has_method("faze2"):
					child.faze2()
var faze3_happened: bool = false:
	set(value):
		faze3_happened = value
		if value:
			for child in get_children():
				if child.has_method("faze3"):
					child.faze3()


func faze1() -> void:
	faze1_happened = true


func faze2() -> void:
	faze2_happened = true


func faze3() -> void:
	faze3_happened = true


func save() -> Dictionary:
	var file: Dictionary = {
		"faze1_happened" = faze1_happened,
		"faze2_happened" = faze2_happened,
		"faze3_happened" = faze3_happened,
	}
	
	return file


func load_save(file: Dictionary) -> void:
	faze1_happened = file["faze1_happened"]
	faze2_happened = file["faze2_happened"]
	faze3_happened = file["faze3_happened"]
