class_name Key
extends PickableItem

@export_enum("red", "blue", "green", "yellow") var key_color := "red"
@export var red_sprite: Texture2D
@export var blue_sprite: Texture2D
@export var yellow_sprite: Texture2D
@export var green_sprite: Texture2D


func _ready() -> void:
	super._ready()
	item_id = key_color
	match key_color:
		"red": $Sprite2D.texture = red_sprite
		"blue": $Sprite2D.texture = blue_sprite
		"green": $Sprite2D.texture = green_sprite
		"yellow": $Sprite2D.texture = yellow_sprite
