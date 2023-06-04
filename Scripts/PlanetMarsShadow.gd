extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
var initial_angle: float
var parent: Node2D
func _ready():
	parent = $"../../"
	initial_angle = transform.get_rotation()
	print('Parent_name: ' + parent.name)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = -parent.rotation
	
