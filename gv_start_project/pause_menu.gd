extends CanvasLayer

# 1. Deklarasi Jembatan ke Audio Bus
# Pastikan di tab Audio (bawah) namanya sudah "Music" dan "SFX"
@onready var music_bus_id = AudioServer.get_bus_index("Music")
@onready var sfx_bus_id = AudioServer.get_bus_index("SFX")

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 2. Menghubungkan Slider agar bisa memerintah Audio Bus
	# Kita pakai script untuk koneksi jalurnya (Signal)
	$Control/MusicSlider.value_changed.connect(_on_music_value_changed)
	$Control/SFXSlider.value_changed.connect(_on_sfx_value_changed)
	
	# Set posisi slider awal agar sesuai dengan volume game sekarang
	if music_bus_id != -1:
		$Control/MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_id))
	if sfx_bus_id != -1:
		$Control/SFXSlider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_id))

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			visible = false
			get_tree().paused = false
		else:
			print("PAUSE")
			visible = true
			get_tree().paused = true

# 3. Fungsi Pengatur Volume (Ini yang bikin slidernya 'hidup')
func _on_music_value_changed(value: float):
	# Mengubah angka slider 0-1 menjadi Decibel
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(value))
	# Mute otomatis kalau ditarik ke paling kiri
	AudioServer.set_bus_mute(music_bus_id, value < 0.01)

func _on_sfx_value_changed(value: float):
	AudioServer.set_bus_volume_db(sfx_bus_id, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_bus_id, value < 0.01)

# --- Fungsi tombol aslimu tetap di bawah sini ---

func _on_button_pressed():
	visible = false
	get_tree().paused = false
	
func _on_to_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMeu/main_menu.tscn")
