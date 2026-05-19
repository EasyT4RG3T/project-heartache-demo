class_name CrawlArea
extends Area3D


var try: bool = false


func _ready() -> void:
	collision_layer = 8
	collision_mask = 8
	monitorable = false
	
	body_entered.connect(_crawl)
	body_exited.connect(_uncrawl)


func _crawl(body: Node3D) -> void:
	try = true
	body.force_crawl = true
	while try:
		if body.current_movement_mode == body.MovementMode.CROUCHING:
			body.change_movement_mode(body.MovementMode.CRAWL)
			try = false
		await get_tree().process_frame


func _uncrawl(body: Node3D) -> void:
	try = false
	body.force_crawl = false
