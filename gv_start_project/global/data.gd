extends Node

const PLAYER_SKINS = {
	Enum.Style.BASIC: preload("res://graphics/characters/main/main_basic.png"),
	Enum.Style.BASEBALL: preload("res://graphics/characters/main/main_blue.png"),
	Enum.Style.COWBOY: preload("res://graphics/characters/main/main_cowboy.png"),
	Enum.Style.ENGLISH: preload("res://graphics/characters/main/main_grey.png"),
	Enum.Style.STRAW: preload("res://graphics/characters/main/main_straw.png"),
	Enum.Style.BEANIE: preload("res://graphics/characters/main/main_red.png")}
const TILE_SIZE = 16
const PLANT_DATA = {
	Enum.Seed.TOMATO: {
		'texture': "res://graphics/plants/tomato.png",
		'icon_texture': "res://graphics/icons/tomato.png",
		'name':'Tomato',
		'h_frames': 3,
		'grow_speed': 0.6,
		'death_max': 3,
		'reward': Enum.Item.TOMATO},
	Enum.Seed.CORN: {
		'texture': "res://graphics/plants/corn.png",
		'icon_texture': "res://graphics/icons/corn.png",
		'name':'Corn',
		'h_frames': 3,
		'grow_speed': 1.0,
		'death_max': 2,
		'reward': Enum.Item.CORN},
	Enum.Seed.PUMPKIN: {
		'texture': "res://graphics/plants/pumpkin.png",
		'icon_texture': "res://graphics/icons/pumpkin.png",
		'name':'Pumpkin',
		'h_frames': 3,
		'grow_speed': 0.3,
		'death_max': 3,
		'reward': Enum.Item.PUMPKIN},
	Enum.Seed.WHEAT: {
		'texture': "res://graphics/plants/wheat.png",
		'icon_texture': "res://graphics/icons/wheat.png",
		'name':'Wheat',
		'h_frames': 3,
		'grow_speed': 1.0,
		'death_max': 3,
		'reward': Enum.Item.WHEAT}}
const MACHINE_UPGRADE_COST = {
	Enum.Machine.DELETE: {},
	Enum.Machine.SPRINKLER: {
		'name': 'Sprinkler',
		'cost' :{Enum.Item.TOMATO: 30, Enum.Item.WHEAT: 20},
		'icon': preload("res://graphics/icons/sprinkler.png"),
		'color': Color.SEA_GREEN},
	Enum.Machine.FISHER: {
		'name': 'Fisher',
		'cost' :{Enum.Item.WOOD: 25, Enum.Item.FISH: 15},
		'icon': preload("res://graphics/icons/fisher.png"),
		'color': Color.SLATE_GRAY},
	Enum.Machine.SCARECROW: {
		'name': 'Scarecrow',
		'cost' : {Enum.Item.PUMPKIN: 15, Enum.Item.CORN: 15},
		'icon': preload("res://graphics/icons/scarecrow.png"),
		'color': Color.BURLYWOOD}}
const HOUSE_COST = {
	1: {Enum.Item.WOOD: 30, Enum.Item.APPLE: 20},
	2: {Enum.Item.WOOD: 40, Enum.Item.APPLE: 30}}
const STYLE_UPGRADES = {
	Enum.Style.BASIC: {},
	Enum.Style.COWBOY: {
		'name': 'Cowboy',
		'cost':{Enum.Item.WOOD: 8, Enum.Item.CORN: 6},
		'icon': preload("res://graphics/icons/cowboy.png"),
		'color': Color.SANDY_BROWN},
	Enum.Style.ENGLISH: {
		'name': 'Oldie',
		'cost':{Enum.Item.CORN: 8, Enum.Item.WHEAT: 6},
		'icon': preload("res://graphics/icons/english.png"),
		'color': Color.LIGHT_GRAY},
	Enum.Style.BASEBALL: {
		'name': 'Baseball',
		'cost':{Enum.Item.TOMATO: 8, Enum.Item.APPLE: 6},
		'icon': preload("res://graphics/icons/blue.png"),
		'color': Color.SKY_BLUE},
	Enum.Style.BEANIE: {
		'name': 'Beanie',
		'cost':{Enum.Item.PUMPKIN: 8, Enum.Item.WHEAT: 6},
		'icon': preload("res://graphics/icons/beanie.png"),
		'color': Color.INDIAN_RED},
	Enum.Style.STRAW: {
		'name': 'Straw',
		'cost':{Enum.Item.FISH: 8, Enum.Item.WOOD: 6},
		'icon': preload("res://graphics/icons/straw.png"),
		'color': Color.BURLYWOOD}}
const TOOL_STATE_ANIMATIONS = {
	Enum.Tool.HOE: 'Hoe',
	Enum.Tool.AXE: 'Axe',
	Enum.Tool.WATER: 'Water',
	Enum.Tool.SWORD: 'Sword',
	Enum.Tool.FISH: 'Fish',
	Enum.Tool.SEED: 'Seed',
	}

const SEED_UPGRADES = {
	Enum.Item.CORN: {
		'name': 'Corn Seed',
		'cost': {Enum.Item.COIN: 10},
		'icon': preload("res://graphics/icons/corn.png"),
		'color': Color.YELLOW},
	Enum.Item.WHEAT: {
		'name': 'Wheat Seed',
		'cost': {Enum.Item.COIN: 8},
		'icon': preload("res://graphics/icons/wheat.png"),
		'color': Color.WHEAT},
	Enum.Item.TOMATO: {
		'name': 'Tomato Seed',
		'cost': {Enum.Item.COIN: 12},
		'icon': preload("res://graphics/icons/tomato.png"),
		'color': Color.TOMATO},
	Enum.Item.PUMPKIN: {
		'name': 'Pumpkin Seed',
		'cost': {Enum.Item.COIN: 15},
		'icon': preload("res://graphics/icons/pumpkin.png"),
		'color': Color.ORANGE}
}

var forecast_rain: bool
var unlocked_styles: Array = [Enum.Style.BASIC, Enum.Style.ENGLISH]
var unlocked_machines: Array = [Enum.Machine.DELETE, Enum.Machine.SPRINKLER, Enum.Machine.FISHER, Enum.Machine.SCARECROW]
var unlocked_seeds: Array = [Enum.Item.CORN, Enum.Item.WHEAT] # Contoh bibit yang sudah terbuka

# Di Data.gd
var shop_connection = {
	Enum.Shop.HAT: {'tracker': unlocked_styles, 'all': STYLE_UPGRADES.keys()},
	Enum.Shop.MAIN: {'tracker': unlocked_machines, 'all': MACHINE_UPGRADE_COST.keys()},
	Enum.Shop.SEEDS: {'tracker': unlocked_seeds, 'all': SEED_UPGRADES.keys()},
	# Gunakan data yang sama dengan SEEDS tapi tracker yang berbeda atau kosong
	Enum.Shop.SELL_SEEDS: {'tracker': [], 'all': SEED_UPGRADES.keys()}, 
}
const DEFAULT_ITEMS := {
	Enum.Item.WOOD: 0,
	Enum.Item.APPLE: 0,
	Enum.Item.FISH: 0,
	Enum.Item.CORN: 0,
	Enum.Item.WHEAT: 0,
	Enum.Item.PUMPKIN: 0,
	Enum.Item.TOMATO: 0,
	Enum.Item.COIN: 10}
	
# inventory runtime (selalu start dari default)
var items: Dictionary = DEFAULT_ITEMS.duplicate(true)
	
func merge_items(loaded: Dictionary) -> void:
	items = DEFAULT_ITEMS.duplicate(true)
	for k in loaded.keys():
		items[k] = loaded[k]
		
var day : int = 1

#func change_item(item: Enum.Item, amount: int = 1, auto_hide: bool = true):
	#items[item] += amount
	#get_tree().get_first_node_in_group("ResourceUI").reveal(auto_hide)

func change_item(item: Enum.Item, amount: int = 1, auto_hide: bool = true) -> void:
	if not items.has(item):
		items[item] = 0
	items[item] += amount

	var ui := get_tree().get_first_node_in_group("ResourceUI")
	if ui:
		ui.reveal(auto_hide)
