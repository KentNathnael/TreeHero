extends CanvasLayer

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

#func _input(event):
	##print("masuk pause")
	#if event.is_action_just_pressed("ui_cancel"):
		#if get_tree().paused:
			#visible = false
			#get_tree().paused = false
		#else:
			#visible = true
			#get_tree().paused = true

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
