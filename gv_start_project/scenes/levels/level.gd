extends Node2D

var plant_scene = preload("res://scenes/objects/plant.tscn")
var used_array : Array[Vector2i]

func _on_player_tool_use(tool: Enum.Tool, pos: Vector2) -> void:
	var grid_coord: Vector2i = Vector2i(int(pos.x / Data.TILE_SIZE), int(pos.y / Data.TILE_SIZE))
	var has_soil = grid_coord in $Layers/SoilLayer.get_used_cells()
	match tool:
		Enum.Tool.HOE:
			var cell = $Layers/GrassLayer.get_cell_tile_data(grid_coord) as TileData
			#if cell and cell.get_custom_data('farmable'):
				#$Layers/SoilLayer.set_cells_terrain_connect([grid_coord], 0, 0)
			print(grid_coord)
		
		Enum.Tool.WATER:
			#var cell = $Layers/SoilLayer.get_cell_tile_data(grid_coord) as Til	eData
			# print(cell)
			#if cell:
				#print("ada cells")
			if has_soil:
				$Layers/SoilWaterLayer.set_cell(grid_coord, 0, Vector2i(randi_range(0,2), 0))
		Enum.Tool.FISH:
			if not grid_coord in $Layers/GrassLayer.get_used_cells():
				print('fishing')
			else: 
				print('not fishing')
			
				
		Enum.Tool.SEED:
			if has_soil and grid_coord not in used_array:
				var plant = plant_scene.instantiate()
				plant.setup(grid_coord, $Objects)
				used_array.append(grid_coord)
		
		Enum.Tool.AXE, Enum.Tool.SWORD:
			for object in get_tree().get_nodes_in_group('Objects'):
				if object.position.distance_to(pos) < 20:
					object.hit(tool)
		
@onready var daytransition_material = $Overlay/CanvasLayer/DayTransitionLayer.material
@export var daytime_color: Gradient


func _process(delta: float) -> void:
	var daytime_point = 1 - ($Timers/DayTimer.time_left / $Timers/DayTimer.wait_time)
	var color = daytime_color.sample(daytime_point)
	$Overlay/DayTimeColor.color = color
	if Input.is_action_just_pressed('day_change'):
		day_restart()
	
func day_restart():
	var tween = create_tween()
	tween.tween_property(daytransition_material, 'shader_parameter/progress', 1.0, 1.0)
	tween.tween_interval(0.5)
	tween.tween_callback(level_reset)
	tween.tween_property(daytransition_material, 'shader_parameter/progress', 0.0, 1.0)

func level_reset():
	for plant in get_tree().get_nodes_in_group('Plants'):
		plant.grow(plant.coord in $Layers/SoilWaterLayer.get_used_cells())
	$Layers/SoilWaterLayer.clear()
	
	$Timers/DayTimer.start()
	for object in get_tree().get_nodes_in_group('Objects'):
		if 'reset' in object:
			object.reset()
