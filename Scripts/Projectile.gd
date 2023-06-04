extends MassiveDestroyable

var SUBGROUP_NAME := "Projectiles"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(SUBGROUP_NAME)
	._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_colision_callback(colision_test: KinematicCollision2D):
	if "SUBGROUP_NAME" in colision_test.collider:
		_take_damage(Vector2.ONE / DAMAGE_PER_SPEED, 1, get_instance_id())
	else:
		.on_colision_callback(colision_test)
	
	


func _on_Timer_timeout():
	queue_free()
