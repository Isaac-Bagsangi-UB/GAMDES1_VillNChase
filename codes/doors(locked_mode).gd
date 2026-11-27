extends Node2D

@export_enum("key", "levers") var unlock_method := "key"

@export_group("Key")
@export_enum("red", "blue", "green", "yellow") var required_key := "red"
@export var red_sprite: Texture2D
@export var blue_sprite: Texture2D
@export var yellow_sprite: Texture2D
@export var green_sprite: Texture2D

@export_group("Levers")
@export var levers: Array[Area2D] = []

@onready var door1: Area2D = $door1
@onready var door2: Area2D = $door2

func _ready() -> void:
	door1.target_door = door2
	door2.target_door = door1
	for d in [door1, door2]:
		d.unlock_method = unlock_method
		d.required_key = required_key
		d.red_sprite = red_sprite
		d.blue_sprite = blue_sprite
		d.green_sprite = green_sprite
		d.yellow_sprite = yellow_sprite
		d.levers = levers
		d._apply_sprite()
