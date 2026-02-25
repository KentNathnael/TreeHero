extends Button

var item_enum
var shop_type: Enum.Shop
var unlock: Array
var source
var is_sell_menu = false # Flag untuk membedakan mode jual/beli

const ICON_PATHS = {
	Enum.Item.WOOD: "res://graphics/icons/wood.png",
	Enum.Item.FISH: "res://graphics/icons/goldfish.png",
	Enum.Item.APPLE: "res://graphics/icons/apple.png",
	Enum.Item.CORN: "res://graphics/icons/corn.png",
	Enum.Item.WHEAT: "res://graphics/icons/wheat.png",
	Enum.Item.PUMPKIN: "res://graphics/icons/pumpkin.png",
	Enum.Item.TOMATO: "res://graphics/icons/tomato.png",
	Enum.Item.COIN: "res://graphics/icons/coin.png"} 

signal press(shop_type: Enum.Shop)

var is_purchasing = false

# Tambahkan parameter sell_mode (default false agar tidak merusak kode lama)
func setup(new_shop_type, new_item_enum, parent):
	item_enum = new_item_enum
	shop_type = new_shop_type
	parent.add_child(self)
	
	# Mapping otomatis berdasarkan Shop Type
	if shop_type == Enum.Shop.HAT:
		source = Data.STYLE_UPGRADES
		unlock = Data.unlocked_styles
	elif shop_type == Enum.Shop.MAIN:
		source = Data.MACHINE_UPGRADE_COST
		unlock = Data.unlocked_machines
	elif shop_type == Enum.Shop.SEEDS:
		source = Data.SEED_UPGRADES 
		unlock = Data.unlocked_seeds
		is_sell_menu = false # Mode Beli
	elif shop_type == Enum.Shop.SELL_SEEDS:
		source = Data.SEED_UPGRADES # Pakai data bibit yang sama
		unlock = [] # Tidak butuh unlock tracker untuk jualan
		is_sell_menu = true # OTOMATIS JADI MODE JUAL
	
	var data = source[item_enum]
	
	# Nama barang (Otomatis nambah "Sell" kalau di menu jual)
	var display_name = data['name']
	if is_sell_menu:
		display_name = "" + display_name
	
	$VBoxContainer/VBoxContainer/Label.text = display_name
	$VBoxContainer/ColorRect.color = data['color']
	$VBoxContainer/ColorRect/TextureRect.texture = data['icon']
	
	var costs = data['cost'].values()
	var keys = data['cost'].keys()
	
# --- SLOT HARGA 1 (Biar Koin Muncul) ---
	$VBoxContainer/VBoxContainer/Control/HBoxContainer/HBoxContainer/Label.text = str(costs[0])
	
	var resource_key_1 = keys[0]
	
	if ICON_PATHS.has(resource_key_1):
		var path = ICON_PATHS[resource_key_1]
		var tex_1 = load(path)
		
		# Ambil node-nya
		var tr_node = $VBoxContainer/VBoxContainer/Control/HBoxContainer/HBoxContainer/TextureRect
		
		if tex_1:
			tr_node.texture = tex_1
			tr_node.show() # PAKSA VISIBLE
			print("Berhasil pasang ikon: ", path)
		else:
			print("Gagal load file di: ", path)
	else:
		print("Key tidak ketemu di ICON_PATHS: ", resource_key_1)
	# SLOT HARGA 2
	if costs.size() > 1:
		var resource_name_2 = Enum.Item.keys()[keys[1]].capitalize()
		$VBoxContainer/VBoxContainer/Control/HBoxContainer/HBoxContainer2/Label.text = str(costs[1])
		var icon_2 = load(ICON_PATHS[keys[1]])
		$VBoxContainer/VBoxContainer/Control/HBoxContainer/HBoxContainer2/TextureRect.texture = icon_2
		$VBoxContainer/VBoxContainer/Control/HBoxContainer/HBoxContainer2.show()
	else:
		$VBoxContainer/VBoxContainer/Control/HBoxContainer/HBoxContainer2.hide()

func _on_focus_entered() -> void:
	$BG.theme_type_variation = "FocusPanel"

func _on_focus_exited() -> void:
	$BG.theme_type_variation = ""

func _on_pressed() -> void:
	if is_purchasing: return
	var cost_dict = source[item_enum]['cost']
	
	if is_sell_menu:
		# --- LOGIKA JUAL ---
		if Data.items[item_enum] > 0:
			is_purchasing = true
			# 1. Kurangi barang dari tas
			Data.change_item(item_enum, -1, false)
			# 2. Tambah koin/resource (Dapet duit)
			for resource in cost_dict.keys():
				Data.change_item(resource, cost_dict[resource], false)
			
			await get_tree().create_timer(0.1).timeout
			press.emit(shop_type)
			is_purchasing = false
		else:
			print("Gak punya barangnya buat dijual, Cuk!")
	else:
		# --- LOGIKA BELI (Original) ---
		var can_afford = true
		for resource in cost_dict.keys():
			if Data.items[resource] < cost_dict[resource]:
				can_afford = false
				break
		
		if can_afford:
			is_purchasing = true
			for resource in cost_dict.keys():
				Data.change_item(resource, -cost_dict[resource], false)
			
			Data.change_item(item_enum, 1, false)
			
			if not item_enum in Data.shop_connection[shop_type]['tracker']:
				Data.shop_connection[shop_type]['tracker'].append(item_enum)
			
			if not item_enum in unlock:
				unlock.append(item_enum)
			
			await get_tree().create_timer(0.1).timeout
			press.emit(shop_type)
			is_purchasing = false
		else:
			print("Resource gak cukup, Cuk!")
