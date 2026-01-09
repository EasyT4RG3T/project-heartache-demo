extends Node3D


@onready var button_01: StaticBody3D = $Geometry/Switches/Button01
@onready var broken_lever_01: StaticBody3D = $Geometry/Switches/BrokenLever01
@onready var pressure_plate_01: StaticBody3D = $Geometry/Switches/PressurePlate01
@onready var hinge_3d: Hinge3D = $Geometry/Doors/Door01/Hinge3D
@onready var slider_3d: Slider3D = $Geometry/Doors/SlideDoor01/Node3D/Slider3D
@onready var slider_3d_2: Slider3D = $Geometry/Doors/SlideDoor01/Node3D2/Slider3D2


@onready var maze_lever: StaticBody3D = $Geometry/Maze/MazeLever
@onready var maze_lights: Node3D = $Geometry/Maze/MazeLights
@onready var maze_lightmap_gi: LightmapGI = $Geometry/Maze/MazeLightmapGI


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
