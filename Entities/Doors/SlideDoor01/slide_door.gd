extends StaticBody3D


@onready var slider_3d: Slider3D = $Node3D/Slider3D
@onready var slider_3d_2: Slider3D = $Node3D2/Slider3D2



func interact(player: PlayerCharacter) -> void:
	slider_3d.interact(player)
	slider_3d_2.interact(player)
