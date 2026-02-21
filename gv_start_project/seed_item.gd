extends Area2D

signal picked_up(type: Enum.Seed)

@export var seed_type: Enum.Seed
@onready var sprite = $Sprite2D
@onready var sfx_player = $AudioStreamPlayer2D # Referensi ke node suara

func _ready():
	body_entered.connect(_on_body_entered)
	setup_visual()

func setup_visual():
	if Data.PLANT_DATA.has(seed_type):
		sprite.texture = load(Data.PLANT_DATA[seed_type]["icon_texture"])

func _on_body_entered(body):
	if body.is_in_group("player") or body.name == "Player":
		# 1. Kirim sinyal ke sistem inventory
		picked_up.emit(seed_type)
		
		# 2. Mainkan suara
		if sfx_player.stream:
			sfx_player.play()
		
		# 3. Matikan visual dan tabrakan agar tidak diambil dua kali
		sprite.hide()
		monitoring = false 
		
		# 4. Tunggu sampai suara selesai baru hapus node-nya
		# Ini supaya suaranya gak terpotong karena queue_free
		sfx_player.finished.connect(queue_free)

		# Opsional: Jika ingin ada jeda maksimal (biar gak nyangkut)
		# get_tree().create_timer(0.5).timeout.connect(queue_free)
