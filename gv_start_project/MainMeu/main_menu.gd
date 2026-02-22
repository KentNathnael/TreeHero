extends Control

var button_type = null

func _on_start_but_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level.tscn")


func _on_option_pressed() -> void:
	get_tree().change_scene_to_file("res://Option_Tutorial/tutorial.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
