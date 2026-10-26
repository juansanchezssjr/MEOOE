extends CharacterBody2D

const SPEED = 300.0

@onready var anim = $texture

var direction := Vector2.ZERO
var last_direction := Vector2.DOWN
var movement_enabled := true

var stats = {
	"health": GAMESTATE.stats['health'],
	"money": 0,
}

func _physics_process(delta: float):
	handle_input()
	handle_animation()
	move_and_slide()
	GAMESTATE.coor = "x [%d] : y [%d]" % [global_position.x, global_position.y]

func handle_input():
	if not movement_enabled:
		direction = Vector2.ZERO
		velocity = Vector2.ZERO
		return
	var input_x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var input_y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if input_x != 0:
		direction = Vector2(sign(input_x), 0)
	elif input_y != 0:
		direction = Vector2(0, sign(input_y))
	else:
		direction = Vector2.ZERO
	velocity = direction * SPEED

func handle_animation():
	if not movement_enabled:
		return
	if direction != Vector2.ZERO:
		last_direction = direction
		play_walk(direction)
	else:
		anim.stop()
		anim.frame = 0
		set_idle_frame()

func play_walk(dir: Vector2):
	var target = ""
	if dir == Vector2.RIGHT: target = "right"
	elif dir == Vector2.LEFT: target = "left"
	elif dir == Vector2.DOWN: target = "down"
	elif dir == Vector2.UP: target = "up"
	if anim.animation != target or not anim.is_playing():
		anim.play(target)
		if anim.frame == 0:
			anim.frame = 1

func set_idle_frame():
	if last_direction == Vector2.RIGHT:
		anim.animation = "right"
	elif last_direction == Vector2.LEFT:
		anim.animation = "left"
	elif last_direction == Vector2.DOWN:
		anim.animation = "down"
	elif last_direction == Vector2.UP:
		anim.animation = "up"

func disable_movement():
	movement_enabled = false
	direction = Vector2.ZERO
	velocity = Vector2.ZERO

func enable_movement():
	movement_enabled = true
