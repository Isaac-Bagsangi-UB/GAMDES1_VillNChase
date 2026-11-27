class_name PickableItem
extends CharacterBody2D

@export var item_id := ""
@export var feet_offset := Vector2(0, 40)
@export var gravity := 980.0

var held_by: Node2D = null
var player_body: Node2D = null
var world_scale := global_scale 

func _ready() -> void:
	$PickupArea.body_entered.connect(_on_body_entered)
	$PickupArea.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if "holding" in body:
		player_body = body


func _on_body_exited(body: Node2D) -> void:
	if body == player_body:
		player_body = null


func _physics_process(delta: float) -> void:
	if held_by:
		return
	velocity.y += gravity * delta
	move_and_slide()


func _process(_delta: float) -> void:
	if held_by:
		if not held_by.is_active(self): # yung na select lang na item nagrereact
			return
		if Input.is_action_just_pressed("drop"):
			drop()
		elif Input.is_action_just_pressed("use"):
			use()
	if Input.is_action_just_pressed("interact"):
		pickup()


func pickup() -> void:
	var player := player_body
	if player == null:
		return
	var index: int = player.get_free_slot() #finding slots
	if index == -1:
		return # no free slot, can't pick up
	player_body = null
	held_by = player
	player.set_slot(self, index) # nireregister yung item sa slot (also sets player.holding if it's the active slot)
	velocity = Vector2.ZERO
	$PickupArea.monitoring = false
	$CollisionShape2D.set_deferred("disabled", true)
	reparent(player.slot_nodes[index], false) # reparent na siya sa item sa loob ng slot (CHANGED: uses the matching slot, not just the active one)
	position = Vector2.ZERO
	global_scale = world_scale  


func drop() -> void:
	var player := held_by
	held_by = null
	player.clear_slot() # CHANGED: was `player.holding = ""`
	reparent(player.get_parent(), true)
	global_position = player.global_position + feet_offset
	$CollisionShape2D.disabled = false
	$PickupArea.monitoring = true


## Override in children. Default: nothing happens (gloves, repair kit, keys).
func use() -> void:
	pass
