extends MassiveDestroyable
class_name Controllable

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float) var torque = PI # radians per second^2
export(float) var c_dry_mass_kg = 1000.0
export(float) var c_fuel_mass_max_kg = 3000.0 
export(float) var c_fuel_consumption = 25.0 # kg per sec
export(float) var c_full_thrust = 2000.0

var target_rotation := NAN
var _c_throttle := 0.0
var _exhaust_node = null
var c_fuel_mass_kg := 1.0

func _ready():
	_exhaust_node = $"./Exhaust"
	c_fuel_mass_kg = c_fuel_mass_max_kg
	._ready()

func get_net_acceleration()->Vector2:
	var net := .get_net_acceleration()
	var accel_because_thrust = (c_full_thrust * _c_throttle)/(c_dry_mass_kg+c_fuel_mass_kg)
	if _c_throttle>0.0 and c_fuel_mass_kg > 0:
		net = net + Vector2.DOWN.rotated(global_rotation) * accel_because_thrust
		if(_exhaust_node != null):
			_exhaust_node.visible = true
	else:
		if(_exhaust_node != null):
			_exhaust_node.visible = false
	return net
	
func _physics_process(delta):
	var local_target_coord := angle_minusPi_to_Pie(target_rotation - get_rotation())
		
	var expected_stop_time = abs(angular_velocity) / torque
	var expected_stop_coord = angle_minusPi_to_Pie(angular_velocity*expected_stop_time+torque*sign(-angular_velocity)*expected_stop_time*expected_stop_time/2)
	if abs(local_target_coord)<(torque*delta*1.3):
		rotation = target_rotation
		angular_velocity = 0
		pass # stop
	elif expected_stop_coord > PI or local_target_coord - expected_stop_coord < 0:
		angular_velocity = angular_velocity - torque*delta
		pass # decrease angular velocity
	elif expected_stop_coord < -PI or local_target_coord - expected_stop_coord > 0:
		angular_velocity = angular_velocity + torque*delta
		
	c_fuel_mass_kg = max(0, c_fuel_mass_kg - c_fuel_consumption * delta * _c_throttle)
	
	._physics_process(delta)
