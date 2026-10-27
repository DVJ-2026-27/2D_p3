extends RigidBody2D

@onready var ground = get_node("../Floor")
@onready var destruction_area_2d: Area2D = $Destruction_Area2D
@onready var explosion_sound: AudioStreamPlayer2D = $explosion

const gravity = 500.0

var impacted := false


func _ready() -> void:
	gravity_scale = gravity / float(
		ProjectSettings.get_setting("physics/2d/default_gravity")
	)

	contact_monitor = true
	max_contacts_reported = 4

func _on_body_entered(body: Node) -> void:
	if impacted:
		return

	if body.is_in_group("Floor") or body.is_in_group("Zombie"):
		impacted = true
		explosion_sound.pitch_scale = randf_range(1.1, 1.3)
		explosion_sound.play()

		if body.is_in_group("Floor"):
			ground.call_deferred("update_polygon_2d", global_position)

		for overlap in destruction_area_2d.get_overlapping_bodies():
			if overlap.is_in_group("Zombie"):
				overlap.die()

		$CollisionShape2D.disabled = true
		visible = false
		await explosion_sound.finished
		queue_free()


func _process(delta: float) -> void:
	$Ball.rotate(5.0 * delta)
