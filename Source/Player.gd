extends KinematicBody

var speed = 10
var velocity = Vector3(0, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if Input.is_action_pressed("ui_up"):
		self.velocity = Vector3(1, 0, 0)
	elif Input.is_action_pressed("ui_down"):
		self.velocity = Vector3(-1, 0, 0)
	else:
		self.velocity = Vector3(0, 0, 0)
	
	var RotationAxis = Vector3(0, 1, 0)
	if Input.is_action_pressed("ui_right"):
		self.rotate_object_local(RotationAxis, -0.02)
	if Input.is_action_pressed("ui_left"):
		self.rotate_object_local(RotationAxis, 0.02)
	
	velocity = velocity.normalized()
	



func _physics_process(delta):
	self.translate_object_local(velocity*speed*delta)
	
	# perform raycasting
	$RayCast.force_raycast_update()
	var origin = $RayCast.global_transform.origin
	if $RayCast.is_colliding():
		
		#move to the ground based on collisison
		#print($RayCast.get_collider())
		var collision_point = $RayCast.get_collision_point()
		var collision_vector = collision_point - origin
		var distance = collision_vector.length()
		var refDistance = 1
		self.translate((collision_vector - (collision_vector / distance * refDistance)) * 1)#0.2)
		
		#align self with raycast collision's normal
		#get normal
		var normal = $RayCast.get_collision_normal()
		DrawLine3d.DrawLine(origin, origin+normal*2, Color(0, 1, 0))
		#get forward direction
		var forward = transform.basis.x
		DrawLine3d.DrawLine(origin, origin+forward*2, Color(1, 0, 0))
		#project forward to normal's perpendicular plane
		var newForward = (forward - (forward.dot(normal) * (normal.normalized()))).normalized()
		DrawLine3d.DrawLine(origin, origin+newForward*2, Color(1, 0, 0))
		#cross product gives last basis vector of transformation X * Y = Z
		var zDir = newForward.cross(normal).normalized()
		DrawLine3d.DrawLine(origin, origin+zDir*2, Color(0, 0, 1))
		#Interpolate between current rotation and target using quaternions
		# Convert basis to quaternion, keep in mind scale is lost
		var a = Quat(transform.basis)
		var newBasis = Basis(newForward, normal, zDir).orthonormalized()
		var b = Quat(newBasis)
		# Interpolate using spherical-linear interpolation (SLERP).
		var c = a.slerp(b,0.05) # find halfway point between a and b
		# Apply back
		transform.basis = Basis(c)

		
#	DrawLine3d.DrawRay(origin, $RayCast.cast_to, Color(1, 0, 0))
	pass
