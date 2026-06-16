extends StaticBody3D


var last_tick: int = 0
var tick: float = 0

const CLOCK_TICKING = preload("uid://c6sy010anaq6j")


func _ready() -> void:
	%AudioStreamPlayer3D.play()


func _physics_process(delta: float) -> void:
	tick += delta
	
	if int(tick) > last_tick:
		%ClockHand.rotate_z(-PI/16)
		
		last_tick = int(tick)
		
		if last_tick >= 6:
			last_tick = 0
			tick = 0.01
			%AudioStreamPlayer3D.play()
