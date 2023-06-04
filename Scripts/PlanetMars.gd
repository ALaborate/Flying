extends MassiveObject
const MARS_RADIUS = 3389.5

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var node: KinematicBody2D
var sprite: Sprite
func _ready():
	var vp_size := get_viewport_rect().size
	node = $"."
	node.position = vp_size/2
	sprite = $"PlanetMars"
	
	
	$"/root/GravityInfo".km_per_px = 2 * MARS_RADIUS / (sprite.texture.get_size().x*sprite.global_scale.x)
	._ready()
#	var te: TextEdit = $'/root/Main/TextEdit'
#	te.text = str(sprite.texture.get_size()*sprite.global_scale.x)+'\n\n'
