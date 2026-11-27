class_name map
extends Node2D

func _ready() -> void:
	$BackgroundMusic.play()

func set_all_volumes(db: float) -> void:
	$BackgroundMusic.volume_db = db
