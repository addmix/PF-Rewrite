extends Spatial
class_name ModularPart

#attachment slots to parent
#only one can be used at a time
var parent_points := []
#attachment slots for children
var child_points := []

var required_parents := []
var required_children := []

var parent_whitelist := PoolStringArray([])
var parent_blacklist := PoolStringArray([])

var child_whitelist := PoolStringArray([])
var child_blacklist := PoolStringArray([])


