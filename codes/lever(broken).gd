class_name BLever
extends Area2D

@export var required_item := "repair_kit"

const TEX_ON = preload("res://Custom assets/LeverOn.png")
const TEX_OFF = preload("res://Custom assets/LeverOff.png")

@onready var broken_sprite: AnimatedSprite2D = $Animated
@onready var fixed_sprite: Sprite2D = $Sprite2D

var is_on := false
var fixed := false

var player_in_range := false
var player_body: Node2D

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

	# Start in the broken state
	broken_sprite.visible = true
	broken_sprite.play()
	fixed_sprite.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("pull me")
		player_in_range = true
		player_body = body
		if not fixed:
			$state.text = "Broken"
			$state.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		player_body = null
		$state.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		if not fixed:
			if player_body.holding == required_item:
				_repair()
			else:
				$DoorLocked.play()
				print("lever is broken")
		else:
			_toggle()

func _repair() -> void:
	fixed = true
	print("lever repaired")
	$state.visible = false

	# Turn off the animated sprite, switch to the normal one
	broken_sprite.stop()
	broken_sprite.visible = false
	fixed_sprite.texture = TEX_OFF
	fixed_sprite.visible = true

	_consume_key_repair_kit()

func _toggle() -> void:
	$UnlockDoor.play()
	is_on = not is_on
	fixed_sprite.texture = TEX_ON if is_on else TEX_OFF
	print("lever is activated" if is_on else "lever is disabled")

func _consume_key_repair_kit() -> void:
	var item = player_body.slots[player_body.active_slot]
	if item and item.item_id == required_item:
		player_body.clear_slot()
		item.queue_free()
