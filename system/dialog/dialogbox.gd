extends CanvasLayer

@onready var msg = $Control/Panel/VBoxContainer/message
@onready var peop = $Control/Panel/VBoxContainer/peop
@onready var all = $"."

var waiting = false
var typing = false

func _ready():
	all.hide()

func say(u, message):
	all.show()
	peop.text = u
	msg.text = message
	msg.visible_characters = 0
	
	waiting = true
	typing = true
	
	start_typing(message)

func start_typing(message):
	for i in message.length():
		msg.visible_characters += 1
		await get_tree().create_timer(0.03).timeout
	
	typing = false

func _process(_delta):
	if waiting and Input.is_action_just_pressed("ui_accept"):
		if typing:
			# termina de escribir instantáneo
			msg.visible_characters = msg.text.length()
			typing = false
		else:
			# cerrar diálogo
			waiting = false
			all.hide()
