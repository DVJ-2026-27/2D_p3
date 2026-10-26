extends RigidBody2D

@onready var floor = get_node("../../Floor")
@onready var destruction_area_2d: Area2D = $Destruction_Area2D


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Floor") or body.is_in_group("Zombie"):
		if floor is StaticBody2D and body.is_in_group("Floor"):
			floor.update_polygon_2d(global_position)

		for overlap in destruction_area_2d.get_overlapping_bodies():
			if overlap.is_in_group("Zombie"):
				overlap.queue_free()

		queue_free()


func _process(delta: float) -> void:
	$Ball.rotate(5.0 * delta)
