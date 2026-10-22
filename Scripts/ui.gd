extends CanvasLayer
@onready var center_container: CenterContainer = $CenterContainer

func show_game_over():
	center_container.show()



func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
