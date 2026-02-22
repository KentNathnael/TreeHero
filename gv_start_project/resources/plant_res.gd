class_name PlantResource extends Resource

@export var texture: Texture2D
@export var icon_texture: Texture2D
@export var grow_speed: float = 1.0
@export var h_frames: int = 3
@export var death_max: int = 3
@export var name: String

var age: float
var death_count: int
var dead: bool:
	set(value):
		dead = value
		emit_changed()
var reward: Enum.Item

func setup(seed_enum: Enum.Seed, reward_item: Enum.Item):
	# Ambil data dari Data.PLANT_DATA (Singleton kamu)
	var data = Data.PLANT_DATA[seed_enum]
	
	texture = load(data['texture'])
	icon_texture = load(data['icon_texture'])
	grow_speed = data['grow_speed']
	h_frames = data['h_frames']
	death_max = data['death_max']
	name = data['name']
	reward = reward_item
	
	# --- LOGIKA NGURANGIN STOK PAS NANAM ---
	# Kita kurangi item yang sesuai dengan tipe hadiahnya (misal: Tomato item)
	# auto_hide = false supaya UI resource tetap kelihatan pas angkanya berkurang
	Data.change_item(reward, -1, false) 
	print("Menanam ", name, ". Stok berkurang 1.")


func grow(sprite: Sprite2D):
	age = min(age + grow_speed, h_frames)
	sprite.frame = int(age)


func decay():
	death_count += 1
	emit_changed()


func get_complete():
	return age >= h_frames


func damage():
	death_count += 1
	emit_changed()
