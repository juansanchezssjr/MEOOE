extends Node2D

const levelpath = "res://control/mission/"

var currentmap = null
var currentlevel = null
var runningflag = true


func _ready():
	startloop()


func startloop():
	processloop()


func processloop() -> void:
	while runningflag:
		await run()
		await get_tree().process_frame


func run() -> void:
	var id = GAMESTATE.strname()
	var map = GAMESTATE.level.get("map", "")

	var pathscrip = levelpath + id + ".gd"
	var pathmap = "res://maps/" + map + ".tscn"

	loadmap(pathmap)

	var level = loadsheet(pathscrip)
	if level == null:
		return

	currentlevel = level

	if level.has_method("start"):
		await level.start(currentmap, GAMESTATE)
	else:
		push_error("invalid level script missing start: " + pathscrip)


func loadmap(path: String) -> void:
	if currentmap:
		currentmap.queue_free()
		currentmap = null

	var packed = load(path)
	if packed == null:
		push_error("map not found: " + path)
		return

	currentmap = packed.instantiate()
	add_child(currentmap)


func loadsheet(path: String):
	var script = load(path)

	if script == null:
		push_error("script not found: " + path)
		return null

	var instance = script.new()

	if not instance.has_method("start"):
		push_error("invalid script no start method: " + path)
		return null

	return instance
