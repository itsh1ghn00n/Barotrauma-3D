extends MeshInstance3D

var coeff : Vector2
var coeff_old : Vector2
var coeff_old_old : Vector2

@export var liquid_mobility: float = 0.0  #from 0 to 1
@export var fill: float = 0.5
@export var glass_thickness: float = 0.1

@onready var pos1 : Vector3 = get_global_transform().origin
@onready var pos2 : Vector3 = pos1
@onready var pos3 : Vector3 = pos2
#onready var transparent_liquid: Material =preload(\"res://transparent liquid in bootle.tres\")
var material_pass_1: Material
var material_pass_2: Material
#var material_pass_3: Material
@export var mat_surface: int =0;
@export var gas: bool = true;
@export var liquid_color : Color = Color(1.0, 1.0, 1.0, 1.0)
var vel:float =0.0
var accell : Vector2

func _ready():
	#get_surface_material(0).material_pass_1.next_pass = transparent_liquid
	#material_pass_2 = get_surface_material(0).material_pass_1.next_pass
	material_pass_1 = get_surface_override_material(mat_surface)
	#material_pass_2 = material_pass_1.next_pass
#	material_pass_3 = material_pass_2.next_pass
	set_glass_thickness(glass_thickness)
	set_liquid_color(liquid_color)
	set_fill(fill)
	material_pass_1.set_shader_parameter("size", Vector2(get_aabb().size.x*0.5,get_aabb().size.y*0.5))
	material_pass_1.set_shader_parameter("scale", get_aabb().size.y*4.0/scale.y)
#	
	
	
func set_fill(value):
	fill = value
	if is_inside_tree():
		material_pass_1.set_shader_parameter("fill_amount",fill)
#		material_pass_3.set_shader_param(\"fill_amount\", (fill*2.0-1.0))

func set_liquid_color(value):
	liquid_color = value
	if is_inside_tree():
		material_pass_1.set_shader_parameter("liquid_color", liquid_color)
#		material_pass_3.set_shader_param(\"liquid_color\", liquid_color)

func set_glass_thickness(value):
	glass_thickness = value
	if is_inside_tree():
		material_pass_1.set_shader_parameter("glass_thickness", glass_thickness*get_aabb().size.x)
#		material_pass_3.set_shader_param(\"glass_thickness\", glass_thickness*get_aabb().size.x*0.5)

func _physics_process(delta):
	var accell_3d:Vector3 = (pos3 - 2 * pos2 + pos1) / delta / delta
	pos1 = pos2
	pos2 = pos3
	pos3 = get_global_transform().origin + rotation
	accell = Vector2(accell_3d.x+accell_3d.y, accell_3d.z+accell_3d.y)
	#accell = Vector2(accell_3d.x, accell_3d.z)
	coeff_old_old = coeff_old
	coeff_old = coeff
	#coeff = delta*delta* (-200.0*coeff_old - 10.0*accell) + 2 * coeff_old - coeff_old_old - delta * 2.0 * (coeff_old - coeff_old_old)
	var spring_constant = 200
	var reaction = 4
	var dampening = 3
	coeff = delta*delta* (-spring_constant*coeff_old - reaction*accell) + 2 * coeff_old - coeff_old_old - delta * dampening * (coeff_old - coeff_old_old)
	var temp: Vector2 = coeff+coeff_old+coeff_old_old
	material_pass_1.set_shader_parameter("coeff", coeff*liquid_mobility)
	#material_pass_3.set_shader_param(\"coeff\", coeff*liquid_mobility)
	if (pos1.distance_to(pos3) < 0.01):
		vel = clamp (vel-delta*1.0,0.0,1.0)
	else:
		vel = 1.0#clamp (vel+delta*1.0,0.0,1.0)
	if !gas:
		vel = 0.0
	material_pass_1.set_shader_parameter("vel", vel)
