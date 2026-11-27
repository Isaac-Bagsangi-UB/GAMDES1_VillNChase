extends CharacterBody2D
var speed_mult := 1.0
var SPEED = 300
var JUMP_VELOCITY = -1000.0
var dead = false
var holding : String = ""
var can_move = true
var knockback_time = 0.0
var is_punching := false
var immune := false # IMMUNITY: set by the immunity potion, blocks all damage
var blink_tween : Tween # BLINK: the tween that blinks the player during invincible time
var heart_loss = preload("res://Custom assets/heart loss.png")
var heart_full = preload("res://Custom assets/heart.png")
var coyote_timer := 0.0
@onready var hearts := [
	$Camera2D/Health, $Camera2D/Health/Health2, $Camera2D/Health/Health3,
	$Camera2D/Health/Health4, $Camera2D/Health/Health5, $Camera2D/Health/Health6,
	$Camera2D/Health/Health7, $Camera2D/Health/Health8, $Camera2D/Health/Health9,
	$Camera2D/Health/Health10,
]
# ▼▼▼ ADDED ▼▼▼
var max_hearts := 10 # how many hearts this difficulty has (set in _ready)
# ▲▲▲ END ADDED ▲▲▲

var slots := [null, null]  # the item in slot1 and slot2
var active_slot := 0
@onready var slot_nodes := [$Camera2D/slot1/Item1, $Camera2D/slot2/Item2]

@export var health := 10

@export var coyote_time = 0.1

func _physics_process(delta: float) -> void:
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

	if Input.is_action_just_pressed("switch_item"):
		switch_item()


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

func clear_slot() -> void: # called by an item when it is dropped or used up
	slots[active_slot] = null
	holding = ""

func is_active(item) -> bool:
	return slots[active_slot] == item

func switch_item() -> void:
	# can't switch mid-punch, otherwise the gloves stop getting frame events
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
	# DIFFICULTY: set the hearts from the chosen difficulty
	health = GameSettings.get_hearts()
	# ▼▼▼ ADDED ▼▼▼
	max_hearts = clamp(health, 0, hearts.size()) # remember this difficulty's heart count
	# the old "hide the hearts that don't exist" loop was removed,
	# update_hearts() now hides the extra hearts from the LEFT
	# ▲▲▲ END ADDED ▲▲▲
	update_hearts()
	# DIFFICULTY: set the normal Timer's time from the chosen difficulty
	# looks under the player first, then anywhere in the current map
	var level_timer = find_child("Timer", true, false)
	if level_timer == null:
		level_timer = get_tree().current_scene.find_child("Timer", true, false)
	if level_timer:
		level_timer.wait_time = GameSettings.get_time_limit()
		if not level_timer.is_stopped():
			level_timer.start() # restart so the new time applies to a timer that's already running
	else:
		push_warning("Timer node not found - difficulty time not applied")

func take_damage(damage:int, source_x = null):
	# DEATH FIX: no more damage (or repeated die() calls from the fall check) once dead
	if dead:
		return
	if not $invincible_time.is_stopped():
		return # ignore the hit
	# IMMUNITY: While immune you still get hurt
	# (sound, knockback, invincibility frames) but the hearts don't go down
	if not immune:
		health -= damage
	$Damaged.play() # SOUND: damaged
	$invincible_time.start()
	start_invincible_blink() # BLINK
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

# BLINK: flashes the character for as long as the invincible_time timer runs
func start_invincible_blink() -> void:
	stop_invincible_blink()
	var step := 0.1 # how long each fade out / fade in takes
	var loops := int(ceil($invincible_time.wait_time / (step * 2.0)))
	blink_tween = create_tween().set_loops(loops)
	blink_tween.tween_property($AnimatedSprite2D, "modulate:a", 0.2, step)
	blink_tween.tween_property($AnimatedSprite2D, "modulate:a", 1.0, step)

func stop_invincible_blink() -> void:
	if blink_tween:
		blink_tween.kill()
	$AnimatedSprite2D.modulate.a = 1.0

# ▼▼▼ ADDED ▼▼▼
# hides the extra hearts from the LEFT and only draws the last max_hearts hearts
func update_hearts() -> void:
	var hidden_count : int = hearts.size() - max_hearts # how many hearts on the left are hidden
	for i in hearts.size():
		if i < hidden_count:
			# self_modulate (not visible) so the child hearts under Health stay shown
			hearts[i].self_modulate.a = 0.0
			continue
		hearts[i].self_modulate.a = 1.0
		var slot_index : int = i - hidden_count # position among the visible hearts, 0 = leftmost
		hearts[i].texture = heart_full if health >= slot_index + 1 else heart_loss
# ▲▲▲ END ADDED ▲▲▲

func movement(delta):
	if not is_on_floor():
		coyote_timer -= delta

	if Input.is_action_just_pressed("move_up") and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY + (100*delta)
		if can_move:
			$Jump.play() # SOUND: jump
		coyote_timer = 0.0

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED

		if Input.is_action_pressed("move_right") and can_move and not is_punching:
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.flip_h = direction < 1
		if Input.is_action_pressed("move_left") and can_move and not is_punching:
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.flip_h = direction < 0

		if not is_on_floor():
			velocity.x /= 1.25
	else:
		velocity.x = move_toward(velocity.x, 0, 500)
		if can_move and not is_punching:
			$AnimatedSprite2D.stop()

func gravity(delta):
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.y += 30
	else:
		coyote_timer = coyote_time
	if position.y > 2000:
		die()

func use(_holding):
	if Input.is_action_just_pressed("use"):
		var item = slots[active_slot]
		if item and item.has_method("use_item"):
			item.use_item(self)

func _on_animated_sprite_2d_frame_changed() -> void:
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
	immune = false # IMMUNITY: clear it on death so nothing lingers
	stop_invincible_blink() # BLINK: don't keep blinking over the death animation
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
	$GameOver.play()
	$Death/Menu.show()
