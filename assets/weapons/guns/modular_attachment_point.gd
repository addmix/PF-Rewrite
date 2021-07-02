extends Node
class_name ModularAttachmentPoint

enum Category {Default, Barrel, Dovetail, Grip, GasBlock, Thread, Tube}

var compatible_categories := PoolStringArray([])

var whitelist := PoolStringArray([])
var blacklist := PoolStringArray([])

var child : ModularPart

func can_add_attachment(attachment : ModularPart) -> bool:
	
	return true

func add_attachment(attachment : ModularPart) -> void:
	child = attachment

func remove_attachment() -> void:
	child = null
