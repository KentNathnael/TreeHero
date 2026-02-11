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
	texture = load(Data.PLANT_DATA[seed_enum]['texture'])
	icon_texture = load(Data.PLANT_DATA[seed_enum]['icon_texture'])
	grow_speed = Data.PLANT_DATA[seed_enum]['grow_speed']
	h_frames = Data.PLANT_DATA[seed_enum]['h_frames']
	death_max = Data.PLANT_DATA[seed_enum]['death_max']
	name = Data.PLANT_DATA[seed_enum]['name']
	reward = reward_item


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
