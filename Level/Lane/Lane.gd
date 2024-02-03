class_name Lane extends ColorRect

var number: int
var width: float

# Called when the node enters the scene tree for the first time.
func _ready():

	$LabelBottom.text = str(number)
	$LabelTop.text = str(number)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
