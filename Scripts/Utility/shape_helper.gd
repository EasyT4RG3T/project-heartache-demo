class_name ShapeHelper
extends Resource


static func create_sphere_mesh(radius: float, color: Color, opacity: float) -> MeshInstance3D:
	var sphere = SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2
	
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.albedo_color.a = opacity
	
	var mesh = MeshInstance3D.new()
	mesh.mesh = sphere
	mesh.material_override = material
	return mesh


static func create_box_mesh(size: Vector3, color: Color, opacity: float) -> MeshInstance3D:
	var box = BoxMesh.new()
	box.size = size
	
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.albedo_color.a = opacity
	
	var mesh = MeshInstance3D.new()
	mesh.mesh = box
	mesh.material_override = material
	return mesh


static func create_capsule_mesh(radius: float, height: float, color: Color, opacity: float) -> MeshInstance3D:
	var capsule = CapsuleMesh.new()
	capsule.radius = radius
	capsule.height = height
	
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.albedo_color.a = opacity
	
	var mesh = MeshInstance3D.new()
	mesh.mesh = capsule
	mesh.material_override = material
	return mesh


static func create_cylinder_mesh(radius: float, height: float, color: Color, opacity: float) -> MeshInstance3D:
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.albedo_color.a = opacity
	
	var mesh = MeshInstance3D.new()
	mesh.mesh = cylinder
	mesh.material_override = material
	return mesh


static func create_sphere_shape(radius: float) -> SphereShape3D:
	var sphere = SphereShape3D.new()
	sphere.radius = radius
	return sphere


static func create_box_shape(size: Vector3) -> BoxShape3D:
	var box = BoxShape3D.new()
	box.size = size
	return box


static func create_capsule_shape(radius: float, height: float) -> CapsuleShape3D:
	var capsule = CapsuleShape3D.new()
	capsule.radius = radius
	capsule.height = height
	return capsule


static func create_cylinder_shape(radius: float, height: float) -> CylinderShape3D:
	var cylinder = CylinderShape3D.new()
	cylinder.radius = radius
	cylinder.height = height
	return cylinder


static func create_query_sphere(radius: float) -> PhysicsShapeQueryParameters3D:
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = create_sphere_shape(radius)
	query.collision_mask = 3
	return query


static func create_query_box(size: Vector3) -> PhysicsShapeQueryParameters3D:
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = create_box_shape(size)
	query.collision_mask = 3
	return query


static func create_query_capsule(radius: float, height: float) -> PhysicsShapeQueryParameters3D:
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = create_capsule_shape(radius, height)
	query.collision_mask = 3
	return query


static func create_query_cylinder(radius: float, height: float) -> PhysicsShapeQueryParameters3D:
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = create_cylinder_shape(radius, height)
	query.collision_mask = 3
	return query
