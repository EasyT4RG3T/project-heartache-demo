class_name SettingsResource
extends Resource


## Game ##

@export var sensitivity: float = 10

@export var max_fps: int = 144
@export var vsync: DisplayServer.VSyncMode = DisplayServer.VSYNC_DISABLED

@export_range(50, 110) var fov: int = 80
@export var dynamic_fov: bool = true

@export var window_mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_FULLSCREEN

@export var hud_size: float = 1.0

@export var static_shader: bool = true


## Audio ##

@export var master_volume: float = 100.0


## Save ##

@export var last_save: String = "0"
