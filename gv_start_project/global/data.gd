extends Node

# dictionary dengan banyaknya data

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
		'texture': "res://graphics/plants/tomato.png",
		'icon_texture': "res://graphics/icons/pumpkin.png",
		'name':'Pumpkin',
		'h_frames': 3,
		'grow_speed': 0.3,
		'death_max': 3,
		'reward': Enum.Item.PUMPKIN},
	Enum.Seed.WHEAT: {
		'texture': "res://graphics/plants/tomato.png",
		'icon_texture': "res://graphics/icons/wheat.png",
		'name':'Wheat',
		'h_frames': 3,
		'grow_speed': 1.0,
		'death_max': 3,
		'reward': Enum.Item.WHEAT}}
const MACHINE_UPGRADE_COST = {
	Enum.Machine.SPRINKLER: {
		'name': 'Sprinkler',
		'cost' :{Enum.Item.TOMATO: 30, Enum.Item.WHEAT: 20},
		'icon': preload("res://graphics/icons/sprinkler.png")},
	Enum.Machine.FISHER: {
		'name': 'Sprinkler',
		'cost' :{Enum.Item.WOOD: 25, Enum.Item.FISH: 15},
		'icon': preload("res://graphics/icons/fisher.png")},
	Enum.Machine.SCARECROW: {
		'name': 'Sprinkler',
		'cost' : {Enum.Item.PUMPKIN: 15, Enum.Item.CORN: 15},
		'icon': preload("res://graphics/icons/scarecrow.png")}}
const HOUSE_COST = {
	1: {Enum.Item.WOOD: 30, Enum.Item.APPLE: 20},
	2: {Enum.Item.WOOD: 40, Enum.Item.APPLE: 30}}
const STYLE_UPGRADES = {
	Enum.Style.COWBOY: {
		'name': 'Cowboy',
		'cost':{Enum.Item.WOOD: 8, Enum.Item.WHEAT: 6},
		'icon': preload("res://graphics/icons/cowboy.png")},
	Enum.Style.ENGLISH: {
		'name': 'Oldie',
		'cost':{Enum.Item.WOOD: 8, Enum.Item.WHEAT: 6},
		'icon': preload("res://graphics/icons/english.png")},
	Enum.Style.BASEBALL: {
		'name': 'Baseball',
		'cost':{Enum.Item.WOOD: 8, Enum.Item.WHEAT: 6},
		'icon': preload("res://graphics/icons/blue.png")},
	Enum.Style.BEANIE: {
		'name': 'Beanie',
		'cost':{Enum.Item.WOOD: 8, Enum.Item.WHEAT: 6},
		'icon': preload("res://graphics/icons/beanie.png")},
	Enum.Style.STRAW: {
		'name': 'Straw',
		'cost':{Enum.Item.WOOD: 8, Enum.Item.WHEAT: 6},
		'icon': preload("res://graphics/icons/straw.png")}}
const TOOL_STATE_ANIMATIONS = {
	Enum.Tool.HOE: 'Hoe',
	Enum.Tool.AXE: 'Axe',
	Enum.Tool.WATER: 'Water',
	Enum.Tool.SWORD: 'Sword',
	Enum.Tool.FISH: 'Fish',
	Enum.Tool.SEED: 'Seed',
	}
