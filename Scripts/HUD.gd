extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
onready var parent = $"../"
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"BluforHealth".value = parent.blufor_ship.health if is_instance_valid(parent.blufor_ship) else 0
	$"OpforHealth".value = parent.opfor_ship.health if is_instance_valid(parent.opfor_ship) else 0
