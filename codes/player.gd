extends CharacterBody2D
# Search for "ADDED" to find everything that isn't your original code.
# Search for "CHANGED" to find what was changed for the gloves-own-the-logic setup.
# Search for "DEATH FIX" to find the changes that disable movement on death.

var speed_mult := 1.0
var SPEED = 300
var JUMP_VELOCITY = -875.0
var dead = false
var holding : String = ""
var can_move = true
var knockback_time = 0.0
var is_punching := false
var heart_loss = preload("res://Custom assets/heart loss.png")
var heart_full = preload("res://Custom assets/heart.png")
# CHANGED: punch_hit was removed. The gloves track it now.

@onready var hearts := [
	$Camera2D/Health, $Camera2D/Health/Health2, $Camera2D/Health/Health3,
	$Camera2D/Health/Health4, $Camera2D/Health/Health5, $Camera2D/Health/Health6,
	$Camera2D/Health/Health7, $Camera2D/Health/Health8, $Camera2D/Health/Health9,
	$Camera2D/Health/Health10,
]

# ▼▼▼ ADDED ▼▼▼
var slots := [null, null]  # the item in slot1 and slot2
var active_slot := 0
@onready var slot_nodes := [$Camera2D/slot1/Item1, $Camera2D/slot2/Item2]
# ▲▲▲ END ADDED ▲▲▲

@export var health := 10

func _physics_process(delta: float) -> void:
	# DEATH FIX: when dead, skip all input/movement/items. Gravity still applies
	# so the body doesn't float if you die mid-jump.
	if dead:
		gravity(delta)
		move_and_slide()
		return

	if can_move == false:
		if is_on_floor():
			is_punching = false # if polymorphed mid-punch, clear the punch state
			$AnimatedSprite2D.play("villie_polymorphed") # ANIMATION: polymorphed
			return
	if can_move == true:
		SPEED = 300 * speed_mult
		JUMP_VELOCITY = -875
	if knockback_time > 0: #youre still knocked backed
		knockback_time -= delta #counter
	else:
		movement(delta)
	move_and_slide()
	gravity(delta)
	$PunchHitbox.scale.x = -1 if $AnimatedSprite2D.flip_h else 1
	use(holding)

	# ▼▼▼ ADDED ▼▼▼
	if Input.is_action_just_pressed("switch_item"):
		switch_item()
	# ▲▲▲ END ADDED ▲▲▲


# ▼▼▼ ADDED ▼▼▼
func get_free_slot() -> int:
	if slots[active_slot] == null:
		return active_slot
	for i in slots.size():
		if slots[i] == null:
			return i
	return -1

func set_slot(item, index: int) -> void:
	slots[index] = item
	if index == active_slot:
		holding = item.item_id
# ▲▲▲ END ADDED ▲▲▲

func clear_slot() -> void: # called by an item when it is dropped or used up
	slots[active_slot] = null
	holding = ""

func is_active(item) -> bool:
	return slots[active_slot] == item

func switch_item() -> void:
	# CHANGED: can't switch mid-punch, otherwise the gloves stop getting frame events
	if is_punching:
		return

	active_slot = (active_slot + 1) % slots.size()
	var item = slots[active_slot]
	holding = item.item_id if item else ""

	var frame_tex = $Camera2D/slot1.texture
	$Camera2D/slot1.texture = $Camera2D/slot2.texture
	$Camera2D/slot2.texture = frame_tex

	var frame_scale = $Camera2D/slot1.scale
	$Camera2D/slot1.scale = $Camera2D/slot2.scale
	$Camera2D/slot2.scale = frame_scale




func _ready():
	pass

func take_damage(damage:int, source_x = null):
	# DEATH FIX: no more damage (or repeated die() calls from the fall check) once dead
	if dead:
		return
	if not $invincible_time.is_stopped():
		return # ignore the hit
	health -= damage
	$Damaged.play() # SOUND: damaged
	$invincible_time.start()
	if source_x != null: # check ng direction for knockback
		var knock_dir = sign(global_position.x - source_x) #hinahanap ang source at nagbibigay ng direction para knockback
		if knock_dir == 0: #pag nasa taas ka ng source
			knock_dir = 1 #right knockback
		velocity.x = knock_dir * 300 #bilis ng knockback
		velocity.y = -300 # talon
		knockback_time = 0.2 #di ka makagalaw pag na knockback

	update_hearts()

	if health <= 0:
		die()

func update_hearts() -> void:
	for i in hearts.size():
		hearts[i].texture = heart_full if health >= i + 1 else heart_loss

func movement(delta):
		# Handle jump. and is_on_floor()
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY + (100*delta)
		if can_move:
			$Jump.play() # SOUND: jump

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED

		if Input.is_action_pressed("move_right") and can_move and not is_punching: # ANIMATION: only walk if can move
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.flip_h = direction < 1
		if Input.is_action_pressed("move_left") and can_move and not is_punching: # ANIMATION: only walk if can move
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.flip_h = direction < 0

		if not is_on_floor():
			velocity.x /= 1.25
	else:
		velocity.x = move_toward(velocity.x, 0, 500) # fixed friction, so knockback still slows down while petrified (SPEED = 0)
		if can_move and not is_punching: # ANIMATION: don't stop the polymorph animation
			$AnimatedSprite2D.stop()

func gravity(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.y += 30

	if position.y > 2000:
		take_damage(100)

func use(_holding):
	if Input.is_action_just_pressed("use"):
		var item = slots[active_slot]
		if item and item.has_method("use_item"):
			item.use_item(self)

func _on_animated_sprite_2d_frame_changed() -> void:
	# DEATH FIX: don't let items fire frame events during the death animation
	if dead:
		return
	var item = slots[active_slot]
	if item and item.has_method("on_frame_changed"):
		item.on_frame_changed(self)

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "villie_attack":
		is_punching = false
		if not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			$AnimatedSprite2D.stop()

func die():
	if dead:
		return
	dead = true
	can_move = false
	velocity = Vector2.ZERO
	knockback_time = 0.0
	is_punching = false
	holding = ""
	$AnimatedSprite2D.play("villie_lose")
	$LoseTimer.start()


func _on_timer_timeout():
	die()


func _on_lose_timer_timeout() -> void:
	health = 0
	print("player died")
	get_tree().paused = true
	$GameOver.play() # SOUND: game over
	$Death/Menu.show()
