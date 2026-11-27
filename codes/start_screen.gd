extends CanvasLayer

@onready var preview: TextureRect = $PanelContainer/Previewarea/Preview

@onready var movement_img: TextureRect = $PanelContainer/Previewarea/movement
@onready var map_objects_img: TextureRect = $PanelContainer/Previewarea/map_objects
@onready var items_img: TextureRect = $PanelContainer/Previewarea/items

@onready var movement_text: Label = $PanelContainer/Previewarea/movement_text
@onready var map_objects_text: Label = $PanelContainer/Previewarea/map_objects_text
@onready var items_text: Label = $PanelContainer/Previewarea/items_text

@onready var movement_btn: TextureButton = $PanelContainer/Margin/VBox/movement_btn
@onready var map_objects_btn: TextureButton = $PanelContainer/Margin/VBox/map_objects_btn
@onready var items_btn: TextureButton = $PanelContainer/Margin/VBox/items_btn


func _ready() -> void:
	add_to_group("start_screen")
	process_mode = Node.PROCESS_MODE_ALWAYS
	movement_btn.button_pressed = true
	get_tree().paused = true


func _on_movement_btn_toggled(toggled_on: bool) -> void:
	_set_preview(movement_img, movement_text, toggled_on)


func _on_map_objects_btn_toggled(toggled_on: bool) -> void:
	_set_preview(map_objects_img, map_objects_text, toggled_on)


func _on_items_btn_toggled(toggled_on: bool) -> void:
	_set_preview(items_img, items_text, toggled_on)


func _set_preview(img: TextureRect, label: Label, show_it: bool) -> void:
	img.visible = show_it
	label.visible = show_it
	preview.visible = not (
		movement_btn.button_pressed
		or map_objects_btn.button_pressed
		or items_btn.button_pressed
	)


func _on_action_pressed() -> void:
	hide()
	get_tree().paused = false
