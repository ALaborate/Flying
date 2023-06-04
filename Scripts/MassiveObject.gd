extends KinematicBody2D
class_name MassiveObject

const GROUP_NAME = "massive"
const THRESHOLD_OF_INFLUECE = 0 # in km^3 * s^-2, meaning such value of std gravitational parameter that it is apllied to other bodies
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float) var std_gravitational_parameter # in km^3 * s^-2
export(float) var angular_velocity # in radians per second
export(Vector2) var linear_velocity: Vector2

var body: KinematicBody2D

func _ready(): # Called when the node enters the scene tree for the first time.
	add_to_group(GROUP_NAME)
	body = $"."
		
static func calculate_acceleration_magnitude(mo: MassiveObject, global_position: Vector2, km_per_px: float) -> float:
	var distance = global_position.distance_to(mo.global_position)
	distance *= km_per_px
#	distance = distance * distance * distance / 7000
#	distance = distance * 10000
	distance = distance * distance
	var acceleration : float = mo.std_gravitational_parameter / distance
	acceleration /= km_per_px
	return acceleration

func get_net_acceleration() -> Vector2:
	var net: Vector2 = Vector2.ZERO
	for _n in get_tree().get_nodes_in_group(GROUP_NAME):
		var n: MassiveObject = _n
		if n.get_instance_id() != get_instance_id():
			if n.std_gravitational_parameter > THRESHOLD_OF_INFLUECE:
				var magnitude : float = calculate_acceleration_magnitude(n, global_position, $"/root/GravityInfo".km_per_px)
				var acceleration: Vector2 = (n.global_position - global_position).normalized()*magnitude
				net = net + acceleration
	return net
	
func on_colision_callback(colision_test):
	pass

func get_net_angular_acceleration() -> float:
	return 0.0
	
var colliding_oobj_name := ''
var first_colision_velocity := Vector2.INF
func _physics_process(delta):
	var net_a:= get_net_acceleration()
	var new_linear_velocity : Vector2 = linear_velocity + net_a*delta
	angular_velocity = angular_velocity + get_net_angular_acceleration()*delta
	
#	body.move_and_slide(linear_velocity)
#	body.move_and_collide(linear_velocity*delta)
	var colision_test := body.move_and_collide(new_linear_velocity*delta, true, true, true)
	if colision_test == null:
		linear_velocity = new_linear_velocity
#		body.global_position = body.global_position + linear_velocity*delta + net_a*delta*delta*0.5 # it does not work correctly for no apparent reason
		body.global_position = body.global_position + linear_velocity*delta
		if first_colision_velocity != Vector2.INF and (first_colision_velocity.length_squared()==0.0 or linear_velocity.dot(first_colision_velocity)/(first_colision_velocity.length()*linear_velocity.length()) < 0.7):
			colliding_oobj_name = ''
			first_colision_velocity = Vector2.INF
	else:
		colision_test.normal
		if (colision_test.position - global_position).dot(net_a)<0.0:
			linear_velocity = new_linear_velocity # allow acceleration from the object
		if colision_test.collider.name != colliding_oobj_name:
			on_colision_callback(colision_test)
			colliding_oobj_name = colision_test.collider.name
			first_colision_velocity = linear_velocity
		
	body.global_rotation = body.global_rotation + angular_velocity*delta
