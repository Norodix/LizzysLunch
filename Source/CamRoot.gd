extends Spatial

#Code and node setup from 
#https://github.com/JohnnyRouddro/Godot_Third_Person_Controller/blob/master/Player/Camera.gd

var camrot_h = 0
var camrot_v = 0
var cam_v_max = 75
var cam_v_min = -55
var h_sensitivity = 0.005
var v_sensitivity = 0.005
var h_acceleration = 10
var v_acceleration = 10



# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$H/V/ClippedCamera.add_exception(get_parent())
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseMotion:
		#$mouse_control_stay_delay.start()
		camrot_h += -event.relative.x * h_sensitivity
		camrot_v += -event.relative.y * v_sensitivity


func _physics_process(delta):
	
	camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
	
	#var mesh_front = get_node("../Mesh").global_transform.basis.z
	#var rot_speed_multiplier = 0.15 #reduce this to make the rotation radius larger
	#var auto_rotate_speed =  (PI - mesh_front.angle_to($h.global_transform.basis.z)) * get_parent().velocity.length() * rot_speed_multiplier
	
#	if $mouse_control_stay_delay.is_stopped():
#		#FOLLOW CAMERA
#		$h.rotation.y = lerp_angle($h.rotation.y, get_node("../Mesh").global_transform.basis.get_euler().y, delta * auto_rotate_speed)
#		camrot_h = $h.rotation_degrees.y
#	else:
#		#MOUSE CAMERA
#		$h.rotation_degrees.y = lerp($h.rotation_degrees.y, camrot_h, delta * h_acceleration)

	#$h/v.rotation_degrees.x = lerp($h/v.rotation_degrees.x, camrot_v, delta * v_acceleration)
	$H.rotation.y = camrot_h
	$H/V.rotation.z = camrot_v
	
