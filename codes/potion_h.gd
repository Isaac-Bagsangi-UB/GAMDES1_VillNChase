extends Area2D

@export var potion_type := "health"
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
	if held_by:
		if Input.is_action_just_pressed("drop"):
			drop()
		elif Input.is_action_just_pressed("interact"):
			use()
	elif Input.is_action_just_pressed("interact"):
		pickup()
		
func pickup() -> void:
	var player := player_body
	if player == null or player.holding != "":
		return
	player_body = null
	player.holding = potion_type
	held_by = player
	monitoring = false  # tinatanggal physics on current frame
	position = Vector2(0, -20)  # position
	reparent(player, false)  # pagkalipat ng parent papunta sa player
	# yung pangalawang variable ay kung hindi niya susundan ang parent or no
	
func drop() -> void:
	var player := held_by
	held_by = null
	player.holding = ""      # was potion_type, which was the bug
	reparent(player.get_parent(), true)
	global_position = player.global_position + feet_offset
	monitoring = true

func use() -> void:
	if held_by.health > 0 and held_by.health < 10:
		if held_by.health == 9:
			held_by.health += 1
		else:
			held_by.health += 2
		held_by.holding = "" 
		$DrinkPotion.play()
		print(held_by.health)
		queue_free()
	else:
		pass
