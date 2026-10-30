extends CharacterBody2D

var speed_mult := 1.0
var SPEED = 300
var JUMP_VELOCITY = -875.0
var dead = false
var holding : String = ""
var can_move = true
var knockback_time = 0.0
var is_punching := false


@export var health := 10

func _physics_process(delta: float) -> void:
	if can_move == false:
		SPEED = 0
		JUMP_VELOCITY = 0
		$AnimatedSprite2D.play("villie_polymorphed") # ANIMATION: polymorphed
	if can_move == true:
		SPEED = 500 * speed_mult
		JUMP_VELOCITY = -875
	if knockback_time > 0: #youre still knocked backed
		knockback_time -= delta #counter
	else:
		movement(delta)
	move_and_slide()
	gravity(delta)
	$PunchHitbox.scale.x = -1 if $AnimatedSprite2D.flip_h else 1
	use(holding)
	

func _ready():
	pass
	
func take_damage(damage:int, source_x = null):
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
	if health <= 0: 
		die()
		
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
	
	if position.y > 900:
		take_damage(1)

func use(holding):
	if holding == "gloves" and Input.is_action_just_pressed("interact") and not is_punching:
		is_punching = true
		$AnimatedSprite2D.play("villie_attack")
		for body in $PunchHitbox.get_overlapping_bodies():
			if body != self and body.has_method("take_damage"):
				body.take_damage(1)
				$HitEnemy.play()

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "villie_attack":
		is_punching = false
		if not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			$AnimatedSprite2D.stop()

func die():
	if dead:
		return
	dead = true
	health = 0
	print("player died")
	get_tree().paused = true
	$GameOver.play() # SOUND: game over
	$Death/Menu.show()
	
func _on_timer_timeout():
	die()
