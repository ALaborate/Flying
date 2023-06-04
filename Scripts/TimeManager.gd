extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.time_scale = 1
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("time_faster"):
		Engine.time_scale = Engine.time_scale * 2
	
	if Input.is_action_just_pressed("time_slower"):
		Engine.time_scale = Engine.time_scale / 2
		
	if Input.is_action_pressed("time_faster") and Input.is_action_pressed("time_slower"):
		Engine.time_scale = 1
