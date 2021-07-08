extends CSGBox

export(NodePath) var path
var node

func _ready():
	node = get_node(path)

func _process(delta):
	transform.origin.x = node.position / 0.3048
