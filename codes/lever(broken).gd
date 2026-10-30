class_name BLever
extends Area2D

@export var required_item := "repair_kit"

var is_on := false
var fixed := false

var player_in_range := false
var player_body: Node2D

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("pull me")
		player_in_range = true
		player_body = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		player_body = null

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		if player_body.holding == required_item or fixed:
			if not fixed:
				fixed = true
				print("lever repaired")
			$UnlockDoor.play()
			is_on = not is_on
			if is_on == true:
				print("lever is activated")
				$Sprite2D.texture = load("res://Assets/Final/LeverOn.png")
			if is_on == false:
				print("lever is disabled")
				$Sprite2D.texture = load("res://Assets/Final/LeverOff.png")
		else:
			$DoorLocked.play()
			print("lever is broken")
