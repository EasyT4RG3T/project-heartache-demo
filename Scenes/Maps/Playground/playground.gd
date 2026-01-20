extends Node3D


@onready var button_01: StaticBody3D = $Geometry/Center/Switches/Button01
@onready var broken_lever_01: StaticBody3D = $Geometry/Center/Switches/BrokenLever01
@onready var pressure_plate_01: StaticBody3D = $Geometry/Center/Switches/PressurePlate01
@onready var hinge_3d: Hinge3D = $Geometry/Center/Doors/Door01/Hinge3D
@onready var slider_3d: Slider3D = $Geometry/Center/Doors/SlideDoor01/Node3D/Slider3D
@onready var slider_3d_2: Slider3D = $Geometry/Center/Doors/SlideDoor01/Node3D2/Slider3D2


@onready var maze_lever: StaticBody3D = $Geometry/Maze/MazeLever
@onready var maze_lights: Node3D = $Geometry/Maze/MazeLights
@onready var maze_lightmap_gi: LightmapGI = $Geometry/Maze/MazeLightmapGI

@onready var lever_01: StaticBody3D = $Geometry/Room/Switches/Lever01
@onready var lights: Node3D = $Geometry/Room/Lights
@onready var lightmap_gi: LightmapGI = $Geometry/Room/LightmapGI


func _ready() -> void:
	button_01.pressed.connect(func(): broken_lever_01.reset())
	pressure_plate_01.pressed.connect(hinge_3d.force_open)
	pressure_plate_01.pressed.connect(slider_3d.force_open)
	pressure_plate_01.pressed.connect(slider_3d_2.force_open)
	pressure_plate_01.depressed.connect(hinge_3d.force_close)
	pressure_plate_01.depressed.connect(slider_3d.force_close)
	pressure_plate_01.depressed.connect(slider_3d_2.force_close)
	
	maze_lever.pressed.connect(func():
		maze_lights.show()
		maze_lightmap_gi.show())
	maze_lever.depressed.connect(func():
		maze_lights.hide()
		maze_lightmap_gi.hide())
	
	lever_01.pressed.connect(func():
		lights.show()
		lightmap_gi.show())
	lever_01.depressed.connect(func():
		lights.hide()
		lightmap_gi.hide())
