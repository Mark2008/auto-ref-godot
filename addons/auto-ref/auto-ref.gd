@tool
extends EditorScript
class_name AutoRef


var node_by_type: Dictionary[StringName, Node] = {}
var node_unique: Dictionary[StringName, bool] = {}
var root: Node

var cnt := 0
var change_scene_cnt := 0
var last_cnt := 0

#var p_temp = []

func _run() -> void:
	print("[macro] Start running AutoExportReference")
	var roots := EditorInterface.get_open_scene_roots()
	for r in roots:
		last_cnt = cnt
		run_root(r)
		if last_cnt != cnt:
			change_scene_cnt += 1
		
	print("[macro] End running AutoExportReference")
	if change_scene_cnt == 0:
		print('[macro] Nothing changed')
	else:
		print('[macro] ', 
			change_scene_cnt, ' scenes changed, ',
			cnt, ' properties changed'
		)
	
func run_root(r: Node):
	root = r
	node_by_type.clear()
	node_unique.clear()
	walk(r)
	walk2(r)

func walk(n: Node):
	var script := n.get_script() as Script
	if script:
		var type_name := script.get_global_name()
		if type_name in node_unique.keys():
			node_unique[type_name] = false
		else:
			node_unique[type_name] = true
			node_by_type[type_name] = n
	
	if n == root || n.owner == root:
		for c in n.get_children(true):
			walk(c)

func walk2(n: Node):
	#p_temp.append(n.name)
	
	var props := n.get_property_list()
	for p in props:
		if p.type == Variant.Type.TYPE_OBJECT \
				and p.hint == PropertyHint.PROPERTY_HINT_NODE_TYPE:
			var type_name := p.hint_string as StringName
			var prop = n.get(p.name)
			
			if prop == null \
					and node_by_type.has(type_name) \
					and node_unique[type_name]:
				n.set(p.name, node_by_type[type_name])
				cnt += 1
				#print('updated')
				#print(p_temp)
	
	if n == root || n.owner == root:
		for c in n.get_children():
			walk2(c)
		
	#p_temp.pop_back()
