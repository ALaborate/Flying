extends Node2D

export (PackedScene) var ship_template
export (float) var random_velocity_factor = 3

export (Texture) var opfor_texture
export (String) var opfor_action_prefix = "opfor_"

export (Texture) var blufor_texture
export (String) var blufor_action_prefix = "blufor_"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _instantiate_ship(body_texture, action_prefix):
	var new_ship: FlyghtControl = ship_template.instance()
	var vp_size = get_viewport_rect().size 
	randomize()
	var rand_direction := Vector2(rand_range(-1,1), rand_range(-1, 1)).normalized()
	new_ship.position = vp_size/2 + rand_direction*vp_size.y/4 + rand_direction*rand_range(0, vp_size.y/4)
	new_ship.linear_velocity = Vector2(rand_range(-1,1), rand_range(-1, 1)).normalized()*random_velocity_factor
	new_ship.action_left = action_prefix + new_ship.action_left
	new_ship.action_right = action_prefix + new_ship.action_right
	new_ship.action_up = action_prefix + new_ship.action_up
	new_ship.action_down = action_prefix + new_ship.action_down
	new_ship.name = action_prefix + new_ship.name
	var new_ship_sprite : Sprite = new_ship.get_node("Ship")
	new_ship_sprite.texture = body_texture
	add_child(new_ship)
	return new_ship
	
var blufor_ship: FlyghtControl = null
var opfor_ship: FlyghtControl = null
# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_instance_valid(opfor_ship):
		opfor_ship = _instantiate_ship(opfor_texture, opfor_action_prefix)
	else:
		opfor_ship.c_fuel_mass_kg = opfor_ship.c_fuel_mass_max_kg
	if not is_instance_valid(blufor_ship):
		blufor_ship = _instantiate_ship(blufor_texture, blufor_action_prefix)
	else:
		blufor_ship.c_fuel_mass_kg = blufor_ship.c_fuel_mass_max_kg
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		_ready()
