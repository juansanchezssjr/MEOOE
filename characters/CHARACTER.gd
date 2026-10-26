extends CharacterBody2D

const SKINDEF = "res://characters/textures/000000.png"

@export var charname: String = "NPC"
@export var speed: float = 0.0
@export var cinematic: bool = false

@onready var rProx = $RATIO
@onready var anim = $animations
@onready var texture = $texture
@onready var raycast = {
	1 : $raycast/up,
	2 : $raycast/right,
	3 : $raycast/down,
	4 : $raycast/left
}

const skinpath = "res://characters/textures/"
const BASE_SPEED_MIN = 160.0
const BASE_SPEED_MAX = 220.0
const STUCK_CHECK_INTERVAL = 0.5
const STUCK_THRESHOLD = 10.0

var direction := Vector2.ZERO
var last_dir := Vector2.ZERO
var last_position := Vector2.ZERO
var stuck_timer := 0.0
var blocked_dirs : Array = []
var dir_attempts : Dictionary = {}
var state = State.WANDER
var _wander_active := false

var stats = {
	"health": 100,
	"damage": 0,
	"money": 500
}

enum State { WANDER, IDLE, PASSIVE }

func _ready():
	randomize()
	$__GENERIC.hide()
	speed = randf_range(BASE_SPEED_MIN, BASE_SPEED_MAX)
	loadSkin()
	rProx.body_entered.connect(_on_body_entered)
	if _is_night(GAMESTATE.hour):
		hide()
		set_physics_process(false)
		return
	await get_tree().create_timer(randf_range(0.0, 2.0)).timeout
	start_wander()

func _is_night(hour: int) -> bool:
	return hour >= 23 or hour < 6

func _on_time_tick(_day, hour, _minute):
	if _is_night(hour):
		hide()
		set_physics_process(false)
	else:
		show()
		set_physics_process(true)
		if not _is_wander_running():
			start_wander()

func _is_wander_running() -> bool:
	return _wander_active

func _on_body_entered(body):
	if body == self or not body is CharacterBody2D:
		return
	if state == State.IDLE:
		escape()

func escape():
	state = State.WANDER
	var dir = weighted_dir()
	set_dir(dir)
	await get_tree().create_timer(randf_range(0.8, 1.5)).timeout
	state = State.PASSIVE
	dir = weighted_dir()
	set_dir(dir)
	await get_tree().create_timer(randf_range(1.5, 3.0)).timeout
	set_dir(Vector2.ZERO)

func set_dir(dir: Vector2):
	direction = dir
	if dir == Vector2.LEFT:
		anim.play("move-a")
	elif dir == Vector2.RIGHT:
		anim.play("move-x")
	elif dir == Vector2.UP:
		anim.play("move-y")
	elif dir == Vector2.DOWN:
		anim.play("move-b")
	else:
		anim.stop()

func face(dir: Vector2):
	if dir == Vector2.LEFT:
		anim.play("move-a")
	elif dir == Vector2.RIGHT:
		anim.play("move-x")
	elif dir == Vector2.UP:
		anim.play("move-y")
	elif dir == Vector2.DOWN:
		anim.play("move-b")
	anim.seek(0.0, true)
	anim.stop()

func raycast_for(dir: Vector2) -> RayCast2D:
	if dir == Vector2.UP: return raycast[1]
	if dir == Vector2.RIGHT: return raycast[2]
	if dir == Vector2.DOWN: return raycast[3]
	if dir == Vector2.LEFT: return raycast[4]
	return null

func get_nearby_bodies() -> Array:
	return rProx.get_overlapping_bodies().filter(func(b): return b != self and b is CharacterBody2D)

func is_blocked_by_neighbor(dir: Vector2, neighbors: Array) -> bool:
	for body in neighbors:
		var to_body = (body.global_position - global_position).normalized()
		if to_body.dot(dir) > 0.7:
			return true
	return false

func get_free_dirs() -> Array:
	var map = {
		Vector2.UP: raycast[1],
		Vector2.RIGHT: raycast[2],
		Vector2.DOWN: raycast[3],
		Vector2.LEFT: raycast[4]
	}
	var neighbors = get_nearby_bodies()
	var free = []
	for dir in map:
		if map[dir].is_colliding():
			continue
		if is_blocked_by_neighbor(dir, neighbors):
			continue
		free.append(dir)
	return free

func weighted_dir_excluding(excluded: Array) -> Vector2:
	var free = get_free_dirs()
	for d in excluded:
		free.erase(d)

	var poor = []
	for d in free:
		if dir_attempts.has(d):
			var avg = dir_attempts[d].reduce(func(a, b): return a + b) / dir_attempts[d].size()
			if avg < STUCK_THRESHOLD:
				poor.append(d)
	if free.size() > poor.size():
		for d in poor:
			free.erase(d)

	if free.is_empty():
		return Vector2.ZERO

	var opposite = last_dir * -1
	if free.size() > 1:
		free.erase(opposite)

	if direction in free and randf() < 0.6:
		return direction

	free.erase(direction)
	if free.is_empty():
		return Vector2.ZERO

	var chosen = free[randi() % free.size()]
	last_dir = chosen
	return chosen

func weighted_dir() -> Vector2:
	return weighted_dir_excluding([])

func _check_stuck():
	if direction == Vector2.ZERO:
		last_position = global_position
		return

	var moved = global_position.distance_to(last_position)

	if direction != Vector2.ZERO:
		if not dir_attempts.has(direction):
			dir_attempts[direction] = []
		dir_attempts[direction].append(moved)
		if dir_attempts[direction].size() > 3:
			dir_attempts[direction].pop_front()

	if moved < STUCK_THRESHOLD:
		blocked_dirs.append(direction)
		var dir = weighted_dir_excluding(blocked_dirs)
		if dir == Vector2.ZERO:
			blocked_dirs.clear()
			dir_attempts.clear()
		else:
			set_dir(dir)
	else:
		blocked_dirs.erase(direction)

	last_position = global_position

func random_look():
	var dirs = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	return dirs[randi() % dirs.size()]

func pick_state() -> State:
	var roll = randf()
	if roll < 0.5:
		return State.WANDER
	elif roll < 0.75:
		return State.IDLE
	else:
		return State.PASSIVE

func start_wander():
	_wander_active = true
	while true:
		if cinematic:
			await get_tree().process_frame
			continue
		if not visible:
			_wander_active = false
			return

		state = pick_state()

		match state:
			State.WANDER:
				var dir = weighted_dir()
				set_dir(dir)
				await get_tree().create_timer(randf_range(1.0, 3.0)).timeout
				set_dir(Vector2.ZERO)
				await get_tree().create_timer(randf_range(0.3, 1.0)).timeout

			State.IDLE:
				direction = Vector2.ZERO
				face(random_look())
				await get_tree().create_timer(randf_range(2.0, 5.0)).timeout

			State.PASSIVE:
				var dir = weighted_dir()
				set_dir(dir)
				await get_tree().create_timer(randf_range(3.0, 6.0)).timeout

func move(dir: Vector2, time := 0.0):
	cinematic = true
	set_dir(dir)
	if time > 0:
		await get_tree().create_timer(time).timeout
		set_dir(Vector2.ZERO)
		cinematic = false

func left(time := 0.0):
	return await move(Vector2.LEFT, time)

func right(time := 0.0):
	return await move(Vector2.RIGHT, time)

func up(time := 0.0):
	return await move(Vector2.UP, time)

func down(time := 0.0):
	return await move(Vector2.DOWN, time)

func loadSkin():
	var path = skinpath + charname + ".png"
	if ResourceLoader.exists(path):
		texture.texture = load(path)
	else:
		push_warning("Skin not found: " + path)
		texture.texture = load(SKINDEF)

func _physics_process(_delta):
	if cinematic:
		velocity = Vector2.ZERO
	else:
		var ahead = raycast_for(direction)
		if ahead != null and ahead.is_colliding():
			set_dir(weighted_dir())

		stuck_timer += _delta
		if stuck_timer >= STUCK_CHECK_INTERVAL:
			stuck_timer = 0.0
			_check_stuck()

		var spd = speed * (0.4 if state == State.PASSIVE else 1.0)
		velocity = direction * spd
	move_and_slide()
