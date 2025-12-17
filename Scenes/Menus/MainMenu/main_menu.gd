extends Control


func _on_playground_button_pressed() -> void:
	GameManager.load_playground()
	queue_free()
