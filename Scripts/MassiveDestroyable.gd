extends MassiveObject
class_name MassiveDestroyable

var DAMAGE_PER_SPEED = 0.09


export(Array, String) var what_to_hide_after_death
export(String) var death_explosion_spritesheet_path

onready var health := 1.0
var death_explosion_spritesheet: Sprite
# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	death_explosion_spritesheet = get_node(death_explosion_spritesheet_path) as Sprite
	

var damage_to_be_taken: float = 0.0
func _process(delta):
	if damage_to_be_taken > 0:
		print("%s is taking %.2f damage!" % [name, damage_to_be_taken])
		if damage_to_be_taken > health:
			# death
			for path in what_to_hide_after_death:
				var n : Node2D = get_node_or_null(path)
				if n != null:
					n = n as Node2D
				if n != null:
					n.hide()
		health -= damage_to_be_taken
		damage_to_be_taken = 0.0
	
	if health<0:
		if death_explosion_spritesheet != null:
			var last_frame := death_explosion_spritesheet.hframes * death_explosion_spritesheet.vframes - 1
			if death_explosion_spritesheet.frame == last_frame:
				queue_free()
			else:
				death_explosion_spritesheet.frame = death_explosion_spritesheet.frame + 1
		else:
			queue_free()
	
func _take_damage(relative_velocity: Vector2, damage_directinal_factor: float, caller):
	# for using caller see instance from id
	var ammount : float = relative_velocity.length()*damage_directinal_factor*DAMAGE_PER_SPEED
	damage_to_be_taken = max(damage_to_be_taken, ammount)

static func _calculate_basic_damage_parameters(global_position, linear_velocity, colision_test: KinematicCollision2D) -> Array:
	var md : MassiveDestroyable = colision_test.collider as MassiveDestroyable
	var other_velocity = colision_test.collider_velocity
	if md != null:
		other_velocity = md.linear_velocity	
	var relative_velocity = linear_velocity - other_velocity
	var to_point_of_colision = colision_test.position - global_position
	var velosity_dot_pointoc : float = relative_velocity.dot(to_point_of_colision)
	var damage_directional_factor : float = velosity_dot_pointoc / (relative_velocity.length()*to_point_of_colision.length()) # measures how much the velocity is aligned with direction to contact point, thus compensating for tangent hits
	damage_directional_factor = max(0, damage_directional_factor)
	return [relative_velocity, damage_directional_factor, md]

func on_colision_callback(colision_test: KinematicCollision2D):
	var params = _calculate_basic_damage_parameters(global_position, linear_velocity, colision_test)
	_take_damage(params[0], params[1], colision_test.collider.get_instance_id())
	if params[2] != null:
		params[2]._take_damage(params[0], params[1], get_instance_id())
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
