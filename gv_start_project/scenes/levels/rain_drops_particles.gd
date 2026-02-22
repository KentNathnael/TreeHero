extends GPUParticles2D

func _process(_delta):
	var cam = get_viewport().get_camera_2d()
	if cam:
		# Pindahkan posisi emitter (titik muncul hujan) ke atas kamera
		global_position.x = cam.global_position.x
		global_position.y = cam.global_position.y - 250
