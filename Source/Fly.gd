extends KinematicBody

var DetectionSize = 3
var minimum = Vector3(-20, 0, -40)
var maximum = Vector3(20, 30, 40)
var hasPlacement = false
#for debug purposes, to find good balance in layer2 try numbers
var layer2TryNumber = 100
var counterMode = false
var layer2Count = 0
var layer1Count = 0

func randomPlacement():
	
	var placement = Vector3()
	#do not interrupt flow for too long 
	for i in 10: # try a few times to place the fly
		#get random position within the given area
		randomize()
		placement.x = rand_range(minimum.x, maximum.x)
		placement.y = rand_range(minimum.y, maximum.y)
		placement.z = rand_range(minimum.z, maximum.z)
		
		#put fly in random position
		var space = get_world().get_direct_space_state()
		var query = PhysicsShapeQueryParameters.new()
		var shape = SphereShape.new()
		shape.radius = DetectionSize
		# move shape to random position
		query.transform.origin = placement
		query.set_shape(shape)
		var hits = space.intersect_shape(query, 2)
		if hits.size() == 0:
			#found a non-intersecting position, use this
			#create a ray here and cast it in random directions
			#make the ray only intersect interesting objects at first (layer2)
			var positionFound = false
			var rayLength = (maximum - minimum).length()
			var rayCast
			
			for j in layer2TryNumber:
				var rayDirection = Vector3(randf()-0.5, randf()-0.5, randf()-0.5).normalized()
				rayCast = space.intersect_ray(placement, placement+rayDirection*rayLength, [], 0x02) #only intersect layer2
				if rayCast.empty():
					continue
				placement = rayCast.position - 0.1 * rayDirection
				positionFound = true
				#print("layer2 intersection found")
				layer2Count += 1
				break
			
			#if no interesting intersection found, do the boring ones as well
			if !positionFound:
				#print("No layer2 intersection, going for layer1")
				var rayDirection = Vector3(randf()-0.5, randf()-0.5, randf()-0.5).normalized()
				#this should always return some valid intersection
				rayCast = space.intersect_ray(placement, placement+rayDirection*rayLength, [], 0xff) #intersect all layers now
				if rayCast.empty():
					#this should not happen if limits are set well
					#print("No intersection for ray found at all")
					hasPlacement = false
					return
				placement = rayCast.position + 0.3 * rayCast.normal
				positionFound = true
				layer1Count += 1
				
			self.transform.origin = placement
			#make the normal the up direction for the fly
			var Y = rayCast.normal
			var X = Vector3(Y[2], Y[2], -Y[0]-Y[1])
			if X.length() < 0.01: #make sure it is not degenerative
				X = Vector3(-Y[1]-Y[2], Y[0], Y[0])

			self.transform.basis.x = X
			self.transform.basis.y = Y
			self.transform.basis.z = X.cross(Y)
			self.transform.basis.orthonormalized()
			hasPlacement = true
			return
			
	hasPlacement = false
	#print("Did not find valid position for fly")
	
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	randomPlacement()
	pass # Replace with function body.

func _process(delta):
	if counterMode:
		hasPlacement = false
		print(layer1Count, "   -   ", layer2Count)
	
	if !hasPlacement:
		randomPlacement()
	pass
