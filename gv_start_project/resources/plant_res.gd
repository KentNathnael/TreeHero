class_name PlantResource extends Resource

@export var texture: Texture2D
@export var icon_texture: Texture2D
@export var grow_speed: float = 1.0
@export var h_frames: int = 3
@export var death_max: int = 3
@export var name: String

var age: float
var death_count: int
var _dead: bool = false
var dead: bool:
	get:
		return _dead
	set(value):
		if _dead == value:
			return
		_dead = value
		emit_changed()
var reward: Enum.Item
var seed_enum: int

func setup(seed_enum_in: Enum.Seed, reward_item: Enum.Item, consume_stock: bool = true):	# Ambil data dari Data.PLANT_DATA (Singleton kamu)
	seed_enum = int(seed_enum_in)
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
	if consume_stock:
		Data.change_item(reward, -1, false) 
		print("Menanam ", name, ". Stok berkurang 1.")

func to_save_dict() -> Dictionary:
	return {
		"seed": seed_enum,
		"age": age,
		"death_count": death_count,
		"dead": dead
	}

func apply_save_dict(d: Dictionary) -> void:
	age = float(d.get("age", 0.0))
	death_count = int(d.get("death_count", 0))
	dead = bool(d.get("dead", false))


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
