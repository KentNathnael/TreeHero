extends CanvasLayer

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			#print("UNPAUSE")
			visible = false
			get_tree().paused = false
		else:
			print("PAUSE")
			visible = true
			get_tree().paused = true

func _on_button_pressed():
	#print("RESUME DIKLIK")
	visible = false
	get_tree().paused = false
	
func _on_to_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMeu/main_menu.tscn")
	
