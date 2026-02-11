@tool
extends StaticBody2D

@export_range(0,3,1) var size: int:
	set(value):
		size = value
		$Sprite2D.frame_coords = Vector2i(size, style)
@export_enum('Bush', 'Rock') var style: int:
	set(value):
		style = value
		#$Sprite2D.frame_coords = Vector2i(size, style)
@export var random: bool
@export_tool_button('Randomize', "Callable") var randomizer = randomize


func _ready() -> void:
	if random:
		size = randi_range(0, $Sprite2D.hframes - 1)
		style = [0,1].pick_random()
	$Sprite2D.frame_coords = Vector2i(size, style)
	$CollisionShape2D.disabled = size < 2
	z_index = -1 if size < 2 else 0

#
func randomize():
	size = randi_range(0, $Sprite2D.hframes - 1)
	style = [0,1].pick_random()
	$Sprite2D.frame_coords = Vector2i(size, style)


#@tool
#extends StaticBody2D
#
#var _size: int = 0
#var _style: int = 0
#
#@export_range(0, 3, 1) var size: int:
	#get:
		#return _size
	#set(value):
		#_size = value
		#update_visual()
#
#@export_enum("Bush", "Rock") var style: int:
	#get:
		#return _style
	#set(value):
		#_style = value
		#update_visual()
#
#@export var random: bool = false
#@export_tool_button("Randomize") var randomizer = randomize
#
#func _ready() -> void:
	#if random:
		#randomize()
	#update_physics()
#
#func update_visual():
	#if not is_inside_tree():
		#return
	#$Sprite2D.frame_coords = Vector2i(_size, _style)
	#update_physics()
#
#func update_physics():
	#$CollisionShape2D.disabled = _size < 2
	#z_index = -1 if _size < 2 else 0
#
#func randomize():
	#size = randi_range(0, $Sprite2D.hframes - 1)
	#style = [0, 1].pick_random()
