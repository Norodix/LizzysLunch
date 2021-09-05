extends KinematicBody

var speed = 10
var velocity = Vector3(0, 0, 0)
var fallVelocity =Vector3()
var gravity = 98
var rotationSpeed = PI #radian/sec
var falling = false

var accumulatedNormal = Vector3()
var amountNormal = 0
var accumulatedCollision = Vector3()
var amountCollision = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if !falling:
		if Input.is_action_pressed("ui_up"):
			self.velocity = Vector3(1, 0, 0)
		elif Input.is_action_pressed("ui_down"):
			self.velocity = Vector3(-1, 0, 0)
		else:
			self.velocity = Vector3(0, 0, 0)
		
		var RotationAxis = Vector3(0, 1, 0)
		if Input.is_action_pressed("ui_right"):
			self.rotate_object_local(RotationAxis, -rotationSpeed * delta)
		if Input.is_action_pressed("ui_left"):
			self.rotate_object_local(RotationAxis, rotationSpeed * delta)
		
	velocity = velocity.normalized()
	

func accumulateRayCone(space, rayRadiusTop, rayRadiusBottom, rayNumber, rayLength, rayHeight, weight):
		#create rays in a circle
	for n in rayNumber:
		# ray start and end in local coordinate system
		var angle = (2.0 * PI / rayNumber) * n
		var start_local = Vector3(sin(angle) * rayRadiusTop,     rayHeight, cos(angle) * rayRadiusTop)
		var end_local   = Vector3(sin(angle) * rayRadiusBottom, -rayLength, cos(angle) * rayRadiusBottom)
		# transform to global coordinates
		var start_global = global_transform * start_local
		var end_global = global_transform * end_local
		#perform raycasting
		DrawLine3d.DrawLine(start_global, end_global, Color(1, 1, 0))
		var rayCast = space.intersect_ray(start_global, end_global, [self])
		#accumulate the 
		if !rayCast.empty():
			# check if raycast is pointing towards player
			# if not pointing towards player 
			# this helps if trimeshes are used because they have no real normals
			if (rayCast.normal.dot(rayCast.position - self.global_transform.origin) < 0):
				accumulatedCollision += rayCast.position * weight
				amountCollision += weight
				accumulatedNormal += rayCast.normal * weight
				DrawLine3d.DrawLine(rayCast.position, rayCast.position + rayCast.normal, Color(1, 0, 0))
	pass


func _physics_process(delta):
	
	self.translate_object_local(velocity*speed*delta)
	
	#perform raycasting using the space server
	var space = get_world().direct_space_state
	accumulatedNormal = Vector3()
	amountNormal = 0
	
	accumulatedCollision = Vector3()
	amountCollision = 0
	
#	accumulateRayCone(space, 2,  -3, 10,   3,     1, 1) 
#	accumulateRayCone(space, 0.2, 3, 10,   3,     1, 1) # two pairs of main cones
#	accumulateRayCone(space, 2,  -2, 10, 0.2,   0.2, 5) #shallow forward looking rays
#	accumulateRayCone(space, 2,  -2, 10, -0.2, -0.2, 5) #reverse to turn back in right orientation

	accumulateRayCone(space, 2,  -3, 10, 1.5, 0, 1) 
	accumulateRayCone(space, 0.2, 3, 10, 1.5, 0, 1) # two pairs of main cones
	accumulateRayCone(space, 2,  -2, 10, 0.2, 0.2, 5) #shallow forward looking rays
	accumulateRayCone(space, 2,  -2, 10, -0.2, -0.2, 5) #reverse to turn back in right orientation

	#calculate average collision and normal
	var avgNormal = accumulatedNormal.normalized()
	var avgCollision = accumulatedCollision / amountCollision
	
	# perform calculations based on raycasting
	var origin = self.global_transform.origin
	if (amountCollision > 0):
		falling = false #we are grabbing onto sth, do not fall
		#move to the ground based on collisison
		#print($RayCast.get_collider())
		var collision_point = avgCollision
		var collision_vector = collision_point - origin
		var distance = collision_vector.length()
		var refDistance = 1
		#var targetPosition = origin + collision_vector * (distance - refDistance)
		#var targetPosition = collision_point + avgNormal * refDistance
		var targetNormal = (collision_point + avgNormal * refDistance).dot(avgNormal) * avgNormal.normalized()
		var targetParallel = origin - origin.dot(avgNormal) * avgNormal.normalized()
		var targetPosition = targetNormal + targetParallel
		#self.translate((collision_vector - (collision_vector / distance * refDistance)) * 1)#0.2)
		# by using interpolation large jumping errors can be mitigated somewhat
		# it is also much smoother
		self.translation = lerp(origin, targetPosition, 0.2)
		
		
		#DrawLine3d.DrawLine(targetPosition, targetPosition+avgNormal, Color(0, 0, 1))
		
		#align self with raycast collision's normal
		#get normal
		var normal = avgNormal
		#DrawLine3d.DrawLine(origin, origin+normal*2, Color(0, 1, 0))
		#get forward direction
		var forward = transform.basis.x
		#DrawLine3d.DrawLine(origin, origin+forward*2, Color(1, 0, 0))
		#project forward to normal's perpendicular plane
		var newForward = (forward - (forward.dot(normal) * (normal.normalized()))).normalized()
		#DrawLine3d.DrawLine(origin, origin+newForward*2, Color(1, 0, 0))
		#cross product gives last basis vector of transformation X * Y = Z
		var zDir = newForward.cross(normal).normalized()
		#DrawLine3d.DrawLine(origin, origin+zDir*2, Color(0, 0, 1))
		#Interpolate between current rotation and target using quaternions
		# Convert basis to quaternion, keep in mind scale is lost
		var a = Quat(transform.basis)
		var newBasis = Basis(newForward, normal, zDir).orthonormalized()
		var b = Quat(newBasis)
		# Interpolate using spherical-linear interpolation (SLERP).
		var c = a.slerp(b,0.2) # find halfway point between a and b
		# Apply back
		transform.basis = Basis(c)
	else:
		falling = true
	
	if falling:
		#There are no attachment points, the player should fall down
		fallVelocity += Vector3(0, -1, 0) * gravity * delta
		if fallVelocity.length() > 600:
			fallVelocity = fallVelocity.normalized()*600
		self.transform.origin += fallVelocity * delta
		pass
	
#	DrawLine3d.DrawRay(origin, $RayCast.cast_to, Color(1, 0, 0))
	pass
