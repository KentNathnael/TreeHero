extends Node2D

var plant_scene = preload("res://scenes/objects/plant.tscn")
var plant_info_scene = preload("res://scenes/ui/plant_info.tscn")
var projectile_scene = preload("res://scenes/machines/projectile.tscn")
var blob_scene = preload("res://scenes/objects/blob.tscn")
var machine_scenes = {
	Enum.Machine.SPRINKLER: preload("res://scenes/machines/sprinkler.tscn"),
	Enum.Machine.SCARECROW: preload("res://scenes/machines/scare_crow.tscn"),
	Enum.Machine.FISHER: preload("res://scenes/machines/fisher.tscn")}
var used_cells: Array[Vector2i]
var soil_age: Dictionary = {} 
var _loaded_from_save: bool = false
var _finished_initial_load: bool = false

var raining: bool:
	set(value):
		raining = value
		$Layers/RainFloorParticles.emitting = value
		$Overlay/RainDropsParticles.emitting = value
		$Music/Rain.playing = value

@onready var player = $Objects/Player
@onready var day_transition_material = $Overlay/CanvasLayer/DayTransitionLayer.material
@export var daytime_color: Gradient
@export var rain_color: Color
@export var volume_curve: Curve

const MACHINE_PREVIEW_TEXTURES = {
	Enum.Machine.SPRINKLER: {'texture':preload("res://graphics/icons/sprinkler.png"), 'offset': Vector2i(0,0)},
	Enum.Machine.FISHER: {'texture':preload("res://graphics/icons/fisher.png"), 'offset': Vector2i(0,-4)},
	Enum.Machine.SCARECROW: {'texture':preload("res://graphics/icons/scarecrow.png"), 'offset': Vector2i(0,-4)},
	Enum.Machine.DELETE: {'texture':preload("res://graphics/icons/delete.png"), 'offset': Vector2i(0,0)}}


func _on_player_tool_use(tool: Enum.Tool, pos: Vector2) -> void:
	var grid_coord: Vector2i = Vector2i(int(pos.x / Data.TILE_SIZE), int(pos.y / Data.TILE_SIZE))
	grid_coord.x += -1 if pos.x < 0 else 0
	grid_coord.y += -1 if pos.y < 0 else 0
	var has_soil = grid_coord in $Layers/SoilLayer.get_used_cells()
	
	match tool:
		Enum.Tool.HOE:
			var cell = $Layers/GrassLayer.get_cell_tile_data(grid_coord) as TileData
			if cell and cell.get_custom_data('farmable'):
				$Layers/SoilLayer.set_cells_terrain_connect([grid_coord], 0, 0)
				if soil_age.has(grid_coord):
					soil_age.erase(grid_coord)
				if raining:
					$Layers/SoilWaterLayer.set_cell(grid_coord, 0, Vector2i(randi_range(0,2),0))
			else:
				print("Tanahnya terlalu keras atau ini jalanan!")
				
		Enum.Tool.WATER:
			if has_soil:
				$Layers/SoilWaterLayer.set_cell(grid_coord, 0, Vector2i(randi_range(0,2),0))
				
		Enum.Tool.FISH:
			if not grid_coord in $Layers/GrassLayer.get_used_cells():
				$Objects/Player.start_fishing()
				
		Enum.Tool.SEED:
			if has_soil and grid_coord not in used_cells:
				var selected_item = {
					Enum.Seed.TOMATO: Enum.Item.TOMATO,
					Enum.Seed.WHEAT: Enum.Item.WHEAT,
					Enum.Seed.CORN: Enum.Item.CORN,
					Enum.Seed.PUMPKIN: Enum.Item.PUMPKIN,
				}[player.current_seed]
				
				if Data.items[selected_item] > 0:
					var plant_res = PlantResource.new()
					plant_res.setup($Objects/Player.current_seed, selected_item)
					var plant = plant_scene.instantiate()
					plant.setup(grid_coord, $Objects, plant_res, plant_death)
					used_cells.append(grid_coord)
					
					var plant_info = plant_info_scene.instantiate()
					plant_info.setup(plant_res)
					$Overlay/CanvasLayer/PlantInfoContainer.add(plant_info)
				
		Enum.Tool.AXE, Enum.Tool.SWORD:
			for object in get_tree().get_nodes_in_group('Objects'):
				if object.position.distance_to(pos) < 20:
					object.hit(tool)

func _on_player_diagnose() -> void:
	$Overlay/CanvasLayer/PlantInfoContainer.visible = not $Overlay/CanvasLayer/PlantInfoContainer.visible

func _on_player_day_change() -> void:
	day_restart()

func _on_player_build(current_machine: int) -> void:
	if current_machine != Enum.Machine.DELETE:
		var machine = machine_scenes[current_machine].instantiate()
		machine.setup(player.get_machine_coord(), self, $Objects)
	else:
		for machine in get_tree().get_nodes_in_group('Machines'):
			machine.delete(player.get_machine_coord() / 16)

func _on_player_machine_change(current_machine: int) -> void:
	$Overlay/MachinePreviewSprite.texture = MACHINE_PREVIEW_TEXTURES[current_machine]['texture']

func _on_player_close_shop() -> void:
	$Overlay/CanvasLayer/ShopUI.hide()
	player.current_state = Enum.State.DEFAULT




func _ready() -> void:
	Data.forecast_rain = [true, false].pick_random()
	for character in get_tree().get_nodes_in_group('Characters'):
		character.connect('open_shop', open_shop)
	
	load_progress_if_any()
	_finished_initial_load = true

func _process(_delta: float) -> void:
	var daytime_point = 1 - ($Timers/DayTimer.time_left / $Timers/DayTimer.wait_time)
	var color = daytime_color.sample(daytime_point).lerp(rain_color, 0.5 if raining else 0.0)
	#$Music/BGMusic.volume_db = volume_curve.sample(daytime_point)
	$Overlay/DayTimeColor.color = color
	
	$Overlay/MachinePreviewSprite.visible = player.current_state == Enum.State.BUILDING
	if $Overlay/MachinePreviewSprite.visible:
		$Overlay/MachinePreviewSprite.position = player.get_machine_coord() + MACHINE_PREVIEW_TEXTURES[player.current_machine]['offset']

func build_save_state() -> Dictionary:
	print("[DBG] SoilLayer used:", $Layers/SoilLayer.get_used_cells().size())
	print("[DBG] SoilWaterLayer used:", $Layers/SoilWaterLayer.get_used_cells().size())
	for child in $Layers.get_children():
		if child is TileMap:
			print("[DBG] Layer:", child.name, " used=", child.get_used_cells().size())
	# 1) plants
	var plants_arr: Array = []
	for p in get_tree().get_nodes_in_group("Plants"):
		plants_arr.append({
			"coord": SaveManager.v2i_to_dict(p.coord),
			"res": p.res.to_save_dict()
		})

	# 2) tilemaps
	var soil_cells: Array = []
	for c in $Layers/SoilLayer.get_used_cells():
		soil_cells.append(SaveManager.v2i_to_dict(c))

	var water_cells: Array = []
	for c in $Layers/SoilWaterLayer.get_used_cells():
		water_cells.append(SaveManager.v2i_to_dict(c))

	# 3) used_cells
	var used_cells_arr: Array = []
	for c in used_cells:
		used_cells_arr.append(SaveManager.v2i_to_dict(c))

	# 4) soil_age (Dictionary key Vector2i gak bisa langsung -> JSON)
	var soil_age_arr: Array = []
	for k in soil_age.keys():
		soil_age_arr.append({
			"coord": SaveManager.v2i_to_dict(k),
			"age": int(soil_age[k])
		})

	# 5) machines
	var machines_arr: Array = []
	for m in get_tree().get_nodes_in_group("Machines"):
		# simpan type berdasarkan scene file name (simple & robust untuk project lo)
		var scene_file := m.scene_file_path
		machines_arr.append({
			"scene": scene_file,
			"pos_x": int(m.position.x),
			"pos_y": int(m.position.y)
		})

	return {
		"progress": {
			"scene": get_tree().current_scene.scene_file_path,
			"player_pos": {"x": player.global_position.x, "y": player.global_position.y},
			"items": SaveManager.encode_items(Data.items),
			"forecast_rain": Data.forecast_rain,
			"raining": raining
		},
		"world": {
			"soil_cells": soil_cells,
			"water_cells": water_cells,
			"used_cells": used_cells_arr,
			"soil_age": soil_age_arr,
			"plants": plants_arr,
			"machines": machines_arr
		}
	}

#func rebuild_plant_info_ui() -> void:
	#print("[UI] rebuild_plant_info_ui called")
#
	#var container := $Overlay/CanvasLayer/PlantInfoContainer
	#if container == null:
		#print("[UI] container NOT FOUND")
		#return
#
	## kosongin dulu container
	#for c in container.get_children():
		#c.queue_free()
#
	#var plants := get_tree().get_nodes_in_group("Plants")
	#print("[UI] plants count =", plants.size())
#
	#if plants.is_empty():
		#return
#
	#var last_plant = plants[plants.size() - 1]
#
	#if last_plant and last_plant.has_method("get_plant_resource"):
		#var r: PlantResource = last_plant.get_plant_resource()
#
		#var panel = plant_info_scene.instantiate()
		#panel.setup(r)
#
		#container.add(panel)

func rebuild_plant_info_ui() -> void:
	print("[UI] rebuild_plant_info_ui called")

	# 1) Ambil container yang benar (ini node Control)
	var container := get_node_or_null("Overlay/CanvasLayer/PlantInfoContainer")
	print("[UI] container =", container)
	if container == null:
		print("[UI] PlantInfoContainer NOT FOUND (cek path)")
		return

	# 2) Ambil semua plant yang sudah ke-instantiate
	var plants := get_tree().get_nodes_in_group("Plants")
	print("[UI] plants count =", plants.size())
	if plants.is_empty():
		return

	# 3) Bersihin isi container dulu (biar gak numpuk)
	#    Asumsi isi container ada di VBoxContainer sesuai script kamu
	var vbox := container.get_node_or_null("MarginContainer/ScrollContainer/VBoxContainer")
	if vbox == null:
		print("[UI] VBoxContainer NOT FOUND (cek struktur PlantInfoContainer)")
		return
	for c in vbox.get_children():
		c.queue_free()

	# 4) Recreate panel info untuk tiap plant
	#    Ini penting: kamu harus preload scene panel plant_info (yang extends PanelContainer)
	var info_scene := preload("res://scenes/ui/plant_info.tscn") # <- sesuaikan path beneran
	for p in plants:
		if p == null or not p.has_method("get_plant_resource"):
			continue

		var res : PlantResource = p.get_plant_resource()
		if res == null:
			continue

		var panel := info_scene.instantiate() # PanelContainer
		vbox.add_child(panel)

		# panel harus punya setup(res)
		if panel.has_method("setup"):
			panel.setup(res)
		else:
			print("[UI] panel ga punya setup() ->", panel)

	# 5) Pastikan container kelihatan
	container.visible = true

func apply_save_state(state: Dictionary) -> void:
	if state.is_empty():
		return

	var progress: Dictionary = state.get("progress", {}) as Dictionary
	var world: Dictionary = state.get("world", {}) as Dictionary

	# items
	var saved_items: Dictionary = progress.get("items", {}) as Dictionary
	Data.items = SaveManager.decode_items(saved_items)

	# rain
	Data.forecast_rain = progress.get("forecast_rain", Data.forecast_rain)
	raining = bool(progress.get("raining", false))

	# clear existing world first
	for p in get_tree().get_nodes_in_group("Plants"):
		p.queue_free()
	for m in get_tree().get_nodes_in_group("Machines"):
		m.queue_free()

	await get_tree().process_frame
	
	used_cells.clear()
	soil_age.clear()

	$Layers/SoilLayer.clear()
	$Layers/SoilWaterLayer.clear()

	# restore soil
	var soil_cells: Array = world.get("soil_cells", [])
	var soil_v2is: Array[Vector2i] = []
	for d in soil_cells:
		soil_v2is.append(SaveManager.dict_to_v2i(d))
	if soil_v2is.size() > 0:
		$Layers/SoilLayer.set_cells_terrain_connect(soil_v2is, 0, 0)

	# restore water
	for d in world.get("water_cells", []):
		var c := SaveManager.dict_to_v2i(d)
		$Layers/SoilWaterLayer.set_cell(c, 0, Vector2i(randi_range(0, 2), 0))

	# restore used_cells
	for d in world.get("used_cells", []):
		used_cells.append(SaveManager.dict_to_v2i(d))

	# restore soil_age
	for e in world.get("soil_age", []):
		var c := SaveManager.dict_to_v2i(e.get("coord", {}) as Dictionary)
		soil_age[c] = int(e.get("age", 0))

	# restore plants
	var reward_map := {
		Enum.Seed.TOMATO: Enum.Item.TOMATO,
		Enum.Seed.WHEAT: Enum.Item.WHEAT,
		Enum.Seed.CORN: Enum.Item.CORN,
		Enum.Seed.PUMPKIN: Enum.Item.PUMPKIN,
	}

	for e in world.get("plants", []):
		var coord := SaveManager.dict_to_v2i(e.get("coord", {}) as Dictionary)
		var res_dict: Dictionary = e.get("res", {}) as Dictionary
		var seed := int(res_dict.get("seed", 0))
		var reward_item: Enum.Item = reward_map.get(seed, Enum.Item.TOMATO)

		var plant_res := PlantResource.new()
		plant_res.setup(seed, reward_item, false) # false biar tidak ngurangin inventory saat load
		plant_res.apply_save_dict(res_dict)

		var plant := plant_scene.instantiate()
		plant.setup(coord, $Objects, plant_res, plant_death)
		plant.get_node("FlashSprite2D").frame = int(plant_res.age)

	# restore machines
	for e in world.get("machines", []):
		var scene_path := String(e.get("scene", ""))
		if scene_path == "":
			continue
		var packed := load(scene_path) as PackedScene
		if packed == null:
			continue
		var machine: Node2D = packed.instantiate() as Node2D
		var pos := Vector2i(int(e.get("pos_x", 0)), int(e.get("pos_y", 0)))
		machine.setup(pos, self, $Objects)
	
	await get_tree().process_frame

	rebuild_plant_info_ui()

	# player pos (deferred)
	var pp: Dictionary = progress.get("player_pos", {}) as Dictionary
	call_deferred("_apply_loaded_player_pos", pp)
	
	
func load_progress_if_any() -> void:
	if not SaveManager.has_save():
		print("[LOAD] no save file")
		return

	var state: Dictionary = SaveManager.load_state()
	print("[LOAD] keys=", state.keys())

	apply_save_state(state)
	_loaded_from_save = true

	print("[LOAD] done. SoilLayer used:", $Layers/SoilLayer.get_used_cells().size())


func _apply_loaded_player_pos(pp: Dictionary) -> void:
	player.global_position = Vector2(float(pp.get("x", 0.0)), float(pp.get("y", 0.0)))


func day_restart():
	player.current_state = Enum.State.SHOP 
	
	if player.has_method("set_idle"):
		player.set_idle()
	
	var tween = create_tween()
	tween.tween_property(day_transition_material, "shader_parameter/progress", 1.0, 1.0)
	tween.tween_interval(0.5)
	tween.tween_callback(level_reset)
	tween.tween_property(day_transition_material, "shader_parameter/progress", 0.0, 1.0)
	tween.tween_callback(func(): player.current_state = Enum.State.DEFAULT)

func level_reset():
	Data.day += 1
	for plant in get_tree().get_nodes_in_group('Plants'):
		plant.grow(plant.coord in $Layers/SoilWaterLayer.get_used_cells())
	
	var all_soil = $Layers/SoilLayer.get_used_cells()
	for cell in all_soil:
		if not cell in used_cells:
			soil_age[cell] = soil_age.get(cell, 0) + 1
			if soil_age[cell] >= 3:
				$Layers/SoilLayer.set_cells_terrain_connect([cell], 0, -1)
				$Layers/SoilWaterLayer.set_cell(cell, -1)
				soil_age.erase(cell)
		else:
			soil_age.erase(cell)

	$Layers/SoilWaterLayer.clear()
	$Overlay/CanvasLayer/PlantInfoContainer.update_all()
	
	$Timers/DayTimer.start()
	for object in get_tree().get_nodes_in_group('Objects'):
		if 'reset' in object:
			object.reset()

	raining = Data.forecast_rain
	Data.forecast_rain = [true, false].pick_random()
	
	if raining:
		for cell in $Layers/SoilLayer.get_used_cells():
			$Layers/SoilWaterLayer.set_cell(cell, 0, Vector2i(randi_range(0,2),0))

func plant_death(coord: Vector2i):
	if coord in used_cells:
		used_cells.erase(coord)

func create_projectile(start_pos: Vector2, dir: Vector2):
	var projectile = projectile_scene.instantiate()
	projectile.setup(start_pos, dir)
	$Objects.add_child(projectile)

func water_plants(coord: Vector2i):
	const SOIL_DIRECTIONS = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0), Vector2i(1, 0), Vector2i(-1, 1), 
		Vector2i(0, 1), Vector2i(1, 1)]
	for dir in SOIL_DIRECTIONS:
		var cell = coord + dir
		if cell in $Layers/SoilLayer.get_used_cells():
			$Layers/SoilWaterLayer.set_cell(cell, 0, Vector2i(randi_range(0,2),0))

func _on_blob_timer_timeout() -> void:
	var plants = get_tree().get_nodes_in_group('Plants')
	if plants:
		var blob = blob_scene.instantiate()
		var spawn_points = $BlobSpawnPositions.get_children()
		if spawn_points.size() > 0:
			var pos = spawn_points.pick_random().position
			blob.setup(pos, plants.pick_random(), $Objects)

func open_shop(shop_type: Enum.Shop):
	$Overlay/CanvasLayer/ShopUI.reveal(shop_type)
	player.current_state = Enum.State.SHOP
	

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_progress()
		get_tree().quit()

func save_progress() -> void:
	if not _finished_initial_load:
		print("[SAVE] blocked: initial load not finished")
		return
		
	var state := build_save_state()
	SaveManager.save_state(state)
	
