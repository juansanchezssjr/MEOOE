extends Node

signal health_act(new_health)

var coor = ""

var hour : int = 0
var minute : int = 0


var level = {
	"current" : 1,
	"chapter" : 1,
	"map" : "ohirTown",
	"string" : ""
}

var stats = {
	'health' : 100,
	'money' : 0,
	'dress': 0
}

func setHealth(n: int) -> void:
	stats['health'] = n
	emit_signal('health_act', stats['health'])
	
func healthAmount(amount: int) -> void:
	setHealth(stats['health'] + amount)

func strname():
	var res = str(level["chapter"]) + "-" + str(level["current"])
	level['string'] = res
	return res
