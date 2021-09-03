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
	if $RayCast.is_colliding():
		print($RayCast.get_collider())
		var origin = $RayCast.global_transform.origin
		var collision_point = $RayCast.get_collision_point()
		var collision_vector = collision_point - origin
		var distance = collision_vector.length()
		var refDistance = 1
		self.translate((collision_vector - (collision_vector / distance * refDistance)) * 0.2)
	pass
