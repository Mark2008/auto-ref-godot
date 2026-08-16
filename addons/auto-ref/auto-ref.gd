@tool
extends EditorScript
class_name AutoRef
## `Ctrl + Shift + P` and search `Auto Ref`!!

# for track changes
var cnt := 0


# the numeric values are used for comparison
# same means that `class_name` is identical
# inherit means inherit idk (indirect)
enum State {
	#Nothing = 0,
	Inherit = 1,
	InheritOverlap = 2,
	Same = 3,
	SameOverlap = 4,
}

class Item:
	var state: State
	var node: Node

var root: Node
var pair: Dictionary[StringName, Item] = {}

func run_root(r: Node):
	root = r
	pair.clear()
	
	walk_construct(r)
	walk_assign(r)

func walk_construct(n: Node):
	var script := n.get_script() as Script
	var state := State.Same
	while script:
		var type := script.get_global_name()
		
		if type in pair.keys():
			if pair[type].state < state:
				pair[type].state = state
				pair[type].node = n
			elif pair[type].state == state:
				# change '???' to '???Overlap'
				pair[type].state += 1
		else:
			# make new item
			pair[type] = Item.new()
			pair[type].state = state
			pair[type].node = n
		
		script = script.get_base_script() # if null escape while loop
		state = State.Inherit
	
	# check if it escape current scene
	# (when child node is instanciated scene)
	if n == root || n.owner == root:
		for c in n.get_children(true):
			walk_construct(c)

func walk_assign(n: Node):
	var props := n.get_property_list()
	for p in props:
		if (
			p.type == Variant.Type.TYPE_OBJECT
			and p.hint == PropertyHint.PROPERTY_HINT_NODE_TYPE
		):
			var type_name := p.hint_string as StringName
			var value := n.get(p.name)
			
			if (
				value == null
				and pair.has(type_name)
				and pair[type_name].state % 2 # not '???Overlap'
			):
				n.set(p.name, pair[type_name].node)
				cnt += 1
	
	# check if it escape current scene
	if n == root || n.owner == root:
		for c in n.get_children():
			walk_assign(c)


func _run() -> void:
	print("[macro] Start running AutoExportReference")
	var root := EditorInterface.get_edited_scene_root()
	run_root(root)
		
	print("[macro] End running AutoExportReference")
	if cnt == 0:
		print('[macro] Nothing changed')
	else:
		print('[macro ', cnt, ' properties changed')
