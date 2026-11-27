extends Area2D

@export var target_door: Area2D
@export_enum("key", "levers") var unlock_method := "key"

@export_group("Key")
@export_enum("red", "blue", "green", "yellow") var required_key := "red"
@export var red_sprite: Texture2D
@export var blue_sprite: Texture2D
@export var yellow_sprite: Texture2D
@export var green_sprite: Texture2D

@export_group("Levers")
@export var levers: Array[Area2D] = []

var unlocked := false  # only used by key doors
var player_in_range := false
var player_body: Node2D

func _ready() -> void:
	if unlock_method == "key":
		match required_key:
			"red": $Sprite2D.texture = red_sprite
			"blue": $Sprite2D.texture = blue_sprite
			"green": $Sprite2D.texture = green_sprite
			"yellow": $Sprite2D.texture = yellow_sprite

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		player_body = body
		_update_label()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		player_body = null
		$state.visible = false

func _process(_delta: float) -> void:
	if player_in_range:
		_update_label()

func _update_label() -> void:
	if _can_unlock():
		$state.visible = false
	else:
		$state.text = "LOCKED"
		$state.visible = true

func _can_unlock() -> bool:
	match unlock_method:
		"key":
			if unlocked:
				return true
			return player_body != null and player_body.holding == required_key
		"levers":
			return _all_levers_on()
	return false

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
		if _can_unlock():
			if unlock_method == "key":
				if not unlocked:
					_consume_key()
				unlocked = true
				target_door.unlocked = true  # lets the player return through the other side
			$state.visible = false
			$UnlockDoor.play()
			player_body.global_position = target_door.global_position
			print("teleport")
		else:
			$DoorLocked.play()
			print("door is locked")

func _consume_key() -> void:
	var item = player_body.slots[player_body.active_slot]
	if item is Key:
		player_body.clear_slot()
		item.queue_free()
