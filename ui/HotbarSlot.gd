extends Control
class_name HotbarSlot

@onready var panel: Panel = $Panel
@onready var icon: TextureRect = $Panel/TextureRect

func set_icon(tex: Texture2D):
	icon.texture = tex

func remove_icon() -> void:
	icon.texture = null
	
func highlight(active: bool):
	var sb := panel.get_theme_stylebox("panel").duplicate()
	sb.border_color = Color.WHITE if active else Color.BLACK
	panel.add_theme_stylebox_override("panel", sb)
