extends Control

var tool_enum: Enum.Tool

func setup(new_tool_enum: Enum.Tool, main_texture: Texture2D):
	tool_enum = new_tool_enum
	$TextureRect.texture = main_texture

func highlight(selected: bool):
	var tween = create_tween()
	var target_size = Vector2(20,20) if selected else Vector2(16,16)
	tween.tween_property($TextureRect, 'custom_minimum_size', target_size, -.1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
