extends MassiveDestroyable
class_name FlyghtControl

export(float) var torque = PI # radians per second^2
export(float) var acceleration = 1
export(String) var path_to_marks_line = "./TrajectoryMarx"
export(int) var trajectory_mark_count = 256

export(PackedScene) var projectile: PackedScene
export(float) var reload_time = 3
export(float) var muzzle_distance = 4
export(float) var muzzle_speed = 10
export(float) var attack_blade_max_factor = 10
export(float) var attack_blade_no_effect_threshold = 0.8


# Called when the node enters the scene tree for the first time.
var rb: MassiveObject
var target_rotation := NAN
var line: Line2D
var trajectory_mark_points := []

onready var next_time_to_shoot := Time.get_unix_time_from_system()

var action_left := "left"
var action_right := "right"
var action_down := "down"
var action_up := "up"

func _ready():
	var timer = get_node("VisTimer")
	rb = $'.'
	timer.connect("timeout", self, "_on_VisTimer_timeout")
	line = get_node_or_null(path_to_marks_line)
	._ready()
	pass  # Replace with function body.

func _angle_minusPi_to_Pie(angle_rad: float) -> float:
	return wrapf(angle_rad, -PI, PI)
	while angle_rad<-PI:
		angle_rad+=2*PI
	while angle_rad>PI:
		angle_rad-=2*PI
	return angle_rad

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	._process(delta)
	
	if (global_position - get_viewport_rect().size).length() > get_viewport_rect().size.length()*2:
		_take_damage(Vector2.ONE / DAMAGE_PER_SPEED, 1, get_instance_id())
	
	target_rotation = Vector2.DOWN.angle_to(rb.linear_velocity)
	if Input.is_action_pressed(action_right):
		target_rotation += PI/2
	if Input.is_action_pressed(action_left):
		target_rotation += 3*PI/2
	if Input.is_action_pressed(action_down):
		target_rotation += PI
	target_rotation = fmod(target_rotation, 2*PI)
	
	if Input.is_action_pressed(action_left) and Input.is_action_pressed(action_right):
		var ct := Time.get_unix_time_from_system()
		if ct > next_time_to_shoot and projectile != null:
			# shoot
			next_time_to_shoot = ct + reload_time
			var p: MassiveDestroyable = projectile.instance() as MassiveDestroyable
			assert (p != null)
			var fwd := Vector2.DOWN.rotated(global_rotation)
			$"..".add_child(p)
			p.global_position = global_position+fwd*muzzle_distance
			p.linear_velocity = linear_velocity + fwd*muzzle_speed
#			linear_velocity = linear_velocity - fwd*muzzle_speed/20
			
			
	
	if line != null:
		trajectory_mark_points.push_back(global_position)
		if len(trajectory_mark_points)>trajectory_mark_count:
			trajectory_mark_points.remove(0)
		var globalizet_tmp = []
		for i in range(len(trajectory_mark_points)):
			globalizet_tmp.append((trajectory_mark_points[i] - global_position).rotated(-global_rotation))
		line.points = globalizet_tmp

func get_net_acceleration()->Vector2:
	var net := .get_net_acceleration()
	if Input.is_action_pressed(action_up):
		net = net + Vector2.DOWN.rotated(global_rotation) * acceleration
		$"./Exhaust".visible = true
	else:
		$"./Exhaust".visible = false
	return net
	
		
func _physics_process(delta):
	var local_target_coord := _angle_minusPi_to_Pie(target_rotation - get_rotation())
		
	var expected_stop_time = abs(rb.angular_velocity) / torque
	var expected_stop_coord = _angle_minusPi_to_Pie(rb.angular_velocity*expected_stop_time+torque*sign(-rb.angular_velocity)*expected_stop_time*expected_stop_time/2)
	if abs(local_target_coord)<(torque*delta*1.3):
		rb.rotation = target_rotation
		rb.angular_velocity = 0
		pass # stop
	elif expected_stop_coord > PI or local_target_coord - expected_stop_coord < 0:
		rb.angular_velocity = rb.angular_velocity - torque*delta
		pass # decrease angular velocity
	elif expected_stop_coord < -PI or local_target_coord - expected_stop_coord > 0:
		rb.angular_velocity = rb.angular_velocity + torque*delta
		
	._physics_process(delta)

func on_colision_callback(colision_test: KinematicCollision2D):
	var params := ._calculate_basic_damage_parameters(global_position, linear_velocity, colision_test)
	var relative_velocity : Vector2 = params[0]
	var damage_directional_factor : float = params[1]
	var md := params[2] as MassiveDestroyable
	
	var enemy_attack_blade_factor := 1.0
	if md != null:
		var efwd := Vector2.DOWN.rotated(md.global_rotation)
		var enemy_divergence = max(efwd.dot((global_position-md.global_position).normalized()), attack_blade_no_effect_threshold) # [attack_blade_no_effect_threshold; 1.0]
		enemy_divergence = (enemy_divergence - attack_blade_no_effect_threshold)/abs(1-attack_blade_no_effect_threshold) # [0; 1]
		enemy_attack_blade_factor = lerp(1.0, attack_blade_max_factor, enemy_divergence)  
	_take_damage(relative_velocity, damage_directional_factor*enemy_attack_blade_factor, colision_test.collider.get_instance_id())
	
	
	if md != null:
		var fwd := Vector2.DOWN.rotated(global_rotation)
		var divergence := max(fwd.dot((md.global_position-global_position).normalized()), attack_blade_no_effect_threshold) # [attack_blade_no_effect_threshold; 1.0]
		divergence = (divergence - attack_blade_no_effect_threshold)/abs(1-attack_blade_no_effect_threshold) # [0; 1]
		var my_attack_blade_factor : float = lerp(1.0, attack_blade_max_factor, divergence)
		
		md._take_damage(relative_velocity, damage_directional_factor*my_attack_blade_factor, get_instance_id())
	

func _on_Button_pressed():
	set_process(not is_processing())
	
func _on_VisTimer_timeout():
	pass
