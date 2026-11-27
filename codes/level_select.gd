extends Control

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tutorial_scene.tscn")
	
func _on_map_a_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map_a.tscn")
