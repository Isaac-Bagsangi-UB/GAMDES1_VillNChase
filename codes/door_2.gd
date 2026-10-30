extends Area2D

@export var target_door: Area2D

var player_in_range := false
var player_body: Node2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		player_body = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		player_body = null

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		player_in_range = false
		player_body.global_position = target_door.global_position
		print("teleport")
