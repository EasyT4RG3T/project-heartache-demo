class_name SettingsResource
extends Resource


@export var vsync: DisplayServer.VSyncMode = DisplayServer.VSYNC_DISABLED
@export var max_fps: int = 144

@export_range(50, 110) var fov: float = 80

@export var window_mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_WINDOWED
