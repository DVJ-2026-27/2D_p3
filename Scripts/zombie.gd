
extends CharacterBody2D

@export var speed: float = 80.0
@export var gravity: float = 500.0
@export var target: Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_dead := false


func _ready() -> void:
	add_to_group("Zombie")

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		var direction: float = sign(target.global_position.x - global_position.x)

		velocity.x = direction * speed

		if direction != 0:
			animated_sprite.play("run")
			animated_sprite.flip_h = direction < 0
		else:
			animated_sprite.play("neutral")
	else:
		velocity.x = 0.0
		animated_sprite.play("neutral")

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = max(velocity.y, 0.0)

	move_and_slide()
	for i in get_slide_collision_count():
		var body := get_slide_collision(i).get_collider()

		if body is Node2D and body.is_in_group("Tank"):
			get_tree().quit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Tank"):
		get_tree().quit()
		


func die() -> void:
	if is_dead:
		return

	is_dead = true

	velocity = Vector2.ZERO
	remove_from_group("Zombie")
	set_physics_process(false)
	set_collision_layer_value(1, false)

	death_sound.pitch_scale = randf_range(0.8, 1.5)
	death_sound.play()
	
	animated_sprite.play("death", 4)
	await animated_sprite.animation_finished
	queue_free()
