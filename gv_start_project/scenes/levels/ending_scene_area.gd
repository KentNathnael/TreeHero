extends Area2D

@export var target_goal: int = 50 

@onready var label_info = $CanvasLayer/VBoxContainer/Label
@onready var btn_lanjutkan = $CanvasLayer/VBoxContainer/BtnLanjutkan

func _ready():
	# Sembunyikan wadah utamanya dulu
	$CanvasLayer/VBoxContainer.hide()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Hubungkan klik tombol
	btn_lanjutkan.pressed.connect(_on_lanjutkan_pressed)

func _on_body_entered(body):
	if body.name == "Player":
		#var total_panen = Data.items[Enum.Item.TOMATO] + \
						  #Data.items[Enum.Item.CORN] + \
						  #Data.items[Enum.Item.WHEAT] + \
						  #Data.items[Enum.Item.PUMPKIN]
		var total_coin = Data.items[Enum.Item.COIN]
		
		$CanvasLayer/VBoxContainer.show()
		
		if total_coin >= target_goal:
			label_info.text = "Syarat Terpenuhi! (" + str(total_coin) + "/" + str(target_goal) + ")"
			btn_lanjutkan.show() # Tampilkan tombol klik
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Munculkan kursor mouse
		else:
			var sisa = target_goal - total_coin
			label_info.text = "Butuh " + str(sisa) + " hasil panen lagi untuk menyelesaikan permainan."
			btn_lanjutkan.hide()

func _on_body_exited(body):
	if body.name == "Player":
		$CanvasLayer/VBoxContainer.hide()
		# Optional: sembunyikan mouse lagi kalau player keluar area
		# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_lanjutkan_pressed():
	# Ganti ke scene ending kamu
	get_tree().change_scene_to_file("res://ending_scene.tscn")
