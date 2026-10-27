extends Node2D

const ZOMBIE_SCENE: PackedScene = preload("res://Scenes/zombie.tscn")

@export var target: Node2D

@onready var markers: Node = $Markers
@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.timeout.connect(spawn_zombie)


func spawn_zombie() -> void:
	if not is_instance_valid(target):
		return

	var spawn_markers := markers.get_children()
	if spawn_markers.is_empty():
		return

	var marker := spawn_markers.pick_random() as Marker2D
	if marker == null:
		return

	var zombie := ZOMBIE_SCENE.instantiate() as CharacterBody2D
	if zombie == null:
		return

	get_tree().current_scene.add_child(zombie)
	zombie.global_position = marker.global_position
	zombie.set("target", target)
