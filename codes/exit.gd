extends Area2D

@export var levers: Array[Area2D] = []

const end_scene = preload("res://scenes/complete.tscn")  # adjust to your actual path

var player_in_range := false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		_update_label()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		$state.visible = false

func _process(_delta: float) -> void:
	if player_in_range:
		_update_label()

func _update_label() -> void:
	if _all_levers_on():
		$state.visible = false
	else:
		$state.text = "LOCKED"
		$state.visible = true

func _all_levers_on() -> bool:
	if levers.is_empty():
		return false
	for l in levers:
		if l == null or not ("is_on" in l):
			continue
		if not l.is_on:
			return false
	return true

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		if _all_levers_on():
			$state.visible = false
			_enter_door()
		else:
			$DoorLocked.play()
			print("door is locked")

func _enter_door() -> void:
	print("entered")
	var screen = end_scene.instantiate()
	get_tree().current_scene.add_child(screen)
	get_tree().paused = true
