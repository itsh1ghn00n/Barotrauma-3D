extends Node
class_name item_api

func get_item_manager() -> Node:
	return get_tree().root.get_node("Game/Level/Map/ItemManager")

func get_item_node() -> Node:
	return get_tree().root.get_node("Game/Level/Map/Items")
