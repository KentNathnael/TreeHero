extends Area2D

@export var spawn_path: NodePath
@export var cam_left: int
@export var cam_right: int
@export var cam_top: int
@export var cam_bottom: int
@export var cooldown_time := 0.5  # jeda antar teleport (detik)

var on_cooldown := false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if on_cooldown:
		return
	if not body is CharacterBody2D:
		return

	var spawn := get_node_or_null(spawn_path)
	if spawn == null:
		return

	on_cooldown = true

	# 1️⃣ SET CAMERA LIMIT
	if body.has_node("Camera2D"):
		var cam := body.get_node("Camera2D") as Camera2D
		cam.limit_left = cam_left
		cam.limit_right = cam_right
		cam.limit_top = cam_top
		cam.limit_bottom = cam_bottom
		cam.make_current()
		cam.reset_smoothing()

	# 2️⃣ TELEPORT
	body.global_position = spawn.global_position

	# 3️⃣ FORCE UPDATE CAMERA
	if body.has_node("Camera2D"):
		var cam := body.get_node("Camera2D") as Camera2D
		cam.force_update_scroll()

	# 4️⃣ COOLDOWN
	await get_tree().create_timer(cooldown_time).timeout
	on_cooldown = false
