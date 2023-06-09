extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
onready var parent = $"../"
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(parent.blufor_ship):
		$"Blufor/Health".value = parent.blufor_ship.health
		$"Blufor/Fuel".value = parent.blufor_ship.c_fuel_mass_kg / parent.blufor_ship.c_fuel_mass_max_kg
	else:
		$"Blufor/Health".value = 0
		$"Blufor/Fuel".value = 0
		
	if is_instance_valid(parent.opfor_ship):
		$"Opfor/Health".value = parent.opfor_ship.health
		$"Opfor/Fuel".value = parent.opfor_ship.c_fuel_mass_kg / parent.opfor_ship.c_fuel_mass_max_kg
	else:
		$"Opfor/Health".value = 0
		$"Opfor/Fuel".value = 0
