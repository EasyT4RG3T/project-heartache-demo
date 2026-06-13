extends Node3D


func _ready() -> void:
	%TempWall/Area3D.body_entered.connect(func(player: PlayerCharacter):
		if player.inventory.flashlight.disabled:
			player.add_thought("I need a flashlight")
		else:
			%TempWall.queue_free())
	
	%VentArea3D.body_entered.connect(func(_p):
		get_parent().vent_open = true)
	
