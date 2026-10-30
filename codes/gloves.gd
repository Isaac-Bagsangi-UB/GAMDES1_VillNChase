extends Area2D

@export var item_type := "gloves"
@export var feet_offset := Vector2(0, 40)

var held_by: Node2D = null
var player_body: Node2D = null


func _on_body_entered(body: Node2D) -> void:
	if "holding" in body:
		player_body = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_body:
		player_body = null


func _process(_delta: float) -> void:
	if held_by:
		if Input.is_action_just_pressed("drop"):
			drop()
	elif Input.is_action_just_pressed("interact"):
		pickup()


func pickup() -> void:
	var player := player_body
	if player == null or player.holding != "":
		return
	player_body = null
	player.holding = item_type
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
