extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var vp_width := get_viewport().size.x
	var vp_height := get_viewport().size.y
	var vp_size := get_viewport_rect().size
	
	var scale := vp_size / texture.get_size()
	$".".scale = scale	
	$".".position = Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
