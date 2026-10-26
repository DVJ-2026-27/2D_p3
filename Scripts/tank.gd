extends CharacterBody2D

const speed = 300.0
const jump_force = -400.0
const gravity = 500.0

const bullet_speed = 600.0
const BALL_SCENE = preload("res://Scenes/ball.tscn")

@onready var tank_sprite: AnimatedSprite2D = $CollisionShape2D/AnimatedSprite2D
@onready var cannon: Sprite2D = $Cannon
@onready var trajectory: Line2D = $Trajectory

var cannon_start_position: Vector2


func _ready() -> void:
	cannon_start_position = cannon.position


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		shoot()


func shoot() -> void:
	var ball = BALL_SCENE.instantiate()
	get_tree().current_scene.add_child(ball)

	var direction := (get_global_mouse_position() - cannon.global_position).normalized()

	ball.global_position = $Cannon/mouth.global_position
	ball.linear_velocity = direction * bullet_speed


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = max(velocity.y, 0.0)

	var input_dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = input_dir * speed

	if input_dir < 0:
		tank_sprite.flip_h = true
		cannon.position.x = -cannon_start_position.x
	elif input_dir > 0:
		tank_sprite.flip_h = false
		cannon.position.x = cannon_start_position.x

	if not is_zero_approx(input_dir):
		tank_sprite.play("default")
	else:
		tank_sprite.stop()

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()
	if is_on_floor():
		var normal := get_floor_normal()
		var target_rotation := -atan2(-normal.x, -normal.y)
		rotation = lerp_angle(rotation, target_rotation, 10.0 * delta)

func _process(_delta: float) -> void:
	cannon.look_at(get_global_mouse_position())

	var angle := fposmod(cannon.rotation_degrees, 360.0)
	cannon.flip_v = angle > 90.0 and angle < 270.0
