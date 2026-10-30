extends Area2D

@export var levers: Array[Area2D] = []

const end_scene = preload("res://scenes/complete.tscn")  # adjust to your actual path

var player_in_range := false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		for l in levers:
			if l == null or not ("is_on" in l):
				continue
			if not l.is_on:
				$DoorLocked.play()
				print("door is locked")
				return
		_enter_door()

func _enter_door() -> void:
	print("entered")
	var screen = end_scene.instantiate()
	get_tree().current_scene.add_child(screen)
	get_tree().paused = true
