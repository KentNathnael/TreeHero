extends Node2D

func _on_player_tool_use(tool: Enum.Tool, pos: Vector2) -> void:
	var grid_coord: Vector2i = Vector2i(int(pos.x / Data.TILE_SIZE), int(pos.y / Data.TILE_SIZE))
	match tool:
		Enum.Tool.HOE:
			$Layers/SoilLayer.set_cells_terrain_connect([grid_coord], 0, 0)
			print(grid_coord)
		
		Enum.Tool.WATER:
			var cell = $Layers/SoilLayer.get_cell_tile_data(grid_coord) as TileData
			# print(cell)
			if cell:
				#print("ada cells")
				$Layers/SoilWaterLayer.set_cell(grid_coord, 0, Vector2i(randi_range(0,2), 0))
				
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
	$Timers/DayTimer.start()
