extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$PlayerObject/CamRoot/H/V/ClippedCamera.add_exception($Walls)
	pass # Replace with function body.



func _process(delta):
	if Input.is_action_just_pressed("ui_restart"):
					get_tree().change_scene("res://Title.tscn")
	pass
