@tool
extends EditorScenePostImport


func _post_import(scene: Node) -> Object:
	var to_free: Array[Node] = []
	iterate(scene, to_free)
	for node in to_free:
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
	return scene


func iterate(node, to_free: Array[Node]):
	if node is StaticBody3D:
		to_free.append(node)
		var pos: Vector3
		for child in node.get_children():
			pos = node.position
			if node.get_parent() != null:
				child.reparent(node.get_parent())
				child.position = pos
	for child in node.get_children():
		iterate(child, to_free)
