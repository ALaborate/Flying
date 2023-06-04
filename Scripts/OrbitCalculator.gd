extends Node2D

export(int) var points_quantity = 10
export(float) var time_interval = 1 # seconds
export(int) var calculation_per_point = 4
export(String) var path_to_rigidbody = '../'
export(String) var path_to_line = '../TrajectoryPredictonMarx'
export(float) var acceleration_compensatory_coef = 1
export(float) var acceleration_filter_coef = 0.5

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var line: Line2D
var rb: MassiveObject
# Called when the node enters the scene tree for the first time.
func _ready():
	line = get_node_or_null(path_to_line)
	rb = get_node(path_to_rigidbody)
	
static func _constant_acceleration_step(position: Vector2, velocity: Vector2, acceleration: Vector2, time: float) -> Vector2:
	return position + velocity*time + acceleration*time*time*0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var position : Vector2 = rb.global_position
	var velocity : Vector2 = rb.linear_velocity

	var prev_acceleration := Vector2.INF
	
	var points = []
	for i in range(points_quantity+1):
		var acceleration := Vector2.ZERO
		for _n in get_tree().get_nodes_in_group(MassiveObject.GROUP_NAME):
			# TODO predict movement of massive objects?
			var n: MassiveObject = _n
			if n.body == null or n.body.get_instance_id() != rb.get_instance_id():
				var acceleration_magnitude := MassiveObject.calculate_acceleration_magnitude(n, position, $"/root/GravityInfo".km_per_px)
				acceleration = acceleration + (n.global_position-position).normalized()*acceleration_magnitude
		acceleration *= acceleration_compensatory_coef
		if prev_acceleration == Vector2.INF:
			prev_acceleration = acceleration
		acceleration = 2 * acceleration - prev_acceleration
		
#		var next_position : Vector2 = position + velocity*time_interval
		var next_position : Vector2 = position + velocity*time_interval + acceleration * time_interval * time_interval / 2
		
		var next_velocity : Vector2 = velocity + acceleration * time_interval
		if fmod(i, calculation_per_point) == 0.0:
			points.push_back((next_position-global_position).rotated(-global_rotation))
		
		position = next_position
		velocity = next_velocity
		prev_acceleration = acceleration
	
	if line != null:
#		for i in range(len(points)):
#			points[i] = line.to_local(points[i])
		var new_points := PoolVector2Array(points)
		line.points = new_points
	
	
