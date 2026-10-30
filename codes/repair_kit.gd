class_name RepairKit
extends Area2D

@export var item_name := "repair_kit"
@export var feet_offset := Vector2(0, 40)

var held_by: Node2D = null
var player_body: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if "holding" in body:
		player_body = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_body:
		player_body = null

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and not held_by:
		pickup()
	if Input.is_action_just_pressed("drop") and held_by:
		drop()

func pickup() -> void:
	var player := player_body
	if player == null or player.holding != "":
		return
	player_body = null
	player.holding = item_name
	held_by = player
	monitoring = false
	position = Vector2(0, -20)
	reparent(player, false)

func drop() -> void:
	var player := held_by
	held_by = null
	player.holding = ""
	reparent(player.get_parent(), true)
	global_position = player.global_position + feet_offset
	monitoring = true
