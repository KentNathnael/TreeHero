extends Button

var item_enum
var shop_type: Enum.Shop
var unlock: Array
var source
const ICON_PATHS = {
	Enum.Item.WOOD: "res://graphics/icons/wood.png",
	Enum.Item.FISH: "res://graphics/icons/goldfish.png",
	Enum.Item.APPLE: "res://graphics/icons/apple.png",
	Enum.Item.CORN: "res://graphics/icons/corn.png",
	Enum.Item.WHEAT: "res://graphics/icons/wheat.png",
	Enum.Item.PUMPKIN: "res://graphics/icons/pumpkin.png",
	Enum.Item.TOMATO: "res://graphics/icons/tomato.png"}
signal press(shop_type: Enum.Shop)

# Variabel tambahan untuk mencegah klik ganda yang tidak sengaja
var is_purchasing = false

func setup(new_shop_type, new_item_enum, parent):
	item_enum = new_item_enum
	shop_type = new_shop_type
	parent.add_child(self)
	
	source = Data.STYLE_UPGRADES if shop_type == Enum.Shop.HAT else Data.MACHINE_UPGRADE_COST
	var data = source[item_enum]
	unlock = Data.unlocked_machines if shop_type == Enum.Shop.MAIN else Data.unlocked_styles
	
	$VBoxContainer/VBoxContainer/Label.text = data['name']
	$VBoxContainer/ColorRect.color = data['color']
	$VBoxContainer/ColorRect/TextureRect.texture = data['icon']
	
	# Ambil harga (Safety check jika values kosong)
	var costs = data['cost'].values()
	var keys = data['cost'].keys()
	
	$VBoxContainer/VBoxContainer/Control/HBoxContainer/HBoxContainer/Label.text = str(costs[0])
	$VBoxContainer/VBoxContainer/Control/HBoxContainer/HBoxContainer2/Label.text = str(costs[1])
	
	var icon_1 = load(ICON_PATHS[keys[0]])
	var icon_2 = load(ICON_PATHS[keys[1]])
	$VBoxContainer/VBoxContainer/Control/HBoxContainer/HBoxContainer/TextureRect.texture = icon_1
	$VBoxContainer/VBoxContainer/Control/HBoxContainer/HBoxContainer2/TextureRect.texture = icon_2

func _on_focus_entered() -> void:
	$BG.theme_type_variation = "FocusPanel"

func _on_focus_exited() -> void:
	$BG.theme_type_variation = ""

func _on_pressed() -> void:
	# Jika sedang proses beli, abaikan input lain
	if is_purchasing: return
	
	var cost_enums = source[item_enum]['cost'].keys()
	var cost_values = source[item_enum]['cost'].values()
	
	# Cek resource
	if Data.items[cost_enums[0]] >= cost_values[0] and Data.items[cost_enums[1]] >= cost_values[1]:
		is_purchasing = true # Kunci tombol
		
		# Kurangi item
		Data.change_item(cost_enums[0], -cost_values[0], false)
		Data.change_item(cost_enums[1], -cost_values[1], false)
		
		# Update Tracker
		if not item_enum in Data.shop_connection[shop_type]['tracker']:
			Data.shop_connection[shop_type]['tracker'].append(item_enum)
		
		if not item_enum in unlock:
			unlock.append(item_enum)
		
		# Beri sedikit jeda sebelum refresh UI agar fokus tidak langsung "loncat" dan mencet tombol baru
		await get_tree().create_timer(0.1).timeout
		press.emit(shop_type)
	else:
		print("Resource tidak cukup!")
