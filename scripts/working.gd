extends Node2D


var rnd = RandomNumberGenerator.new()

var from: Button = null
var to: Button = null
var holder0: Button = null

var text: String = FileAccess.open(Singleton.task_path, FileAccess.READ).get_as_text()
var text_bez_n = text.replace('<n///>', '')
var strokes: PackedStringArray = text_bez_n.split('\n')


func swap_from_to(sender: Button) -> void:
	if from == null:
		from = sender
	else:
		to = sender

		var from_parrent: HBoxContainer = from.get_parent()
		var to_parrent: HBoxContainer = to.get_parent()
		
		var from_place: int = child_place(from, from_parrent)
		var to_place: int = child_place(to, to_parrent)
		
		from_parrent.remove_child(from)
		to_parrent.remove_child(to)
		
		from_parrent.add_child(to)
		to_parrent.add_child(from)
		
		from_parrent.move_child(to, from_place)
		to_parrent.move_child(from, to_place)
		
		from = null
		to = null


func but_m_pos(sender: Button) -> Vector2:
	var m_pos: Vector2 = get_global_mouse_position()
	var s_cms: Vector2 = sender.custom_minimum_size
	return Vector2(m_pos.x - (s_cms.x / 2), m_pos.y - (s_cms.y / 2))


func but_add_themes(but: Button) -> void:
	but.add_theme_color_override("font_color",  Color("#000000"))
	but.add_theme_color_override("font_hover_color",  Color("#000000"))
	but.add_theme_color_override("font_pressed_color",  Color("#000000"))
	but.add_theme_color_override("font_focus_color",  Color("#000000"))

	but.add_theme_stylebox_override('hover', load("res://pc_images/vs/hover_flat.tres"))
	but.add_theme_stylebox_override('hover_pressed', load("res://pc_images/vs/hover_flat.tres"))
	but.add_theme_stylebox_override('pressed', load("res://pc_images/vs/hover_flat.tres"))
	but.add_theme_stylebox_override('focus', load("res://pc_images/vs/hover_flat.tres"))

	but.add_theme_stylebox_override('normal', load("res://pc_images/vs/normal_flat.tres"))


func clone_but(sender: Button) -> Button:
	var clone: Button = Button.new()
	clone.text = sender.text
	clone.custom_minimum_size = sender.size
	but_add_themes(clone)
	return clone


func child_place(sender: Button, parrent: HBoxContainer) -> int:
	var place: int = 0
	for child in parrent.get_children():
		if child == sender:
			break
		place += 1
	return place


func but_up(sender: Button) -> void:
	remove_child(holder0)
	
	var was_any: bool = false
	
	var m_pos: Vector2 = get_global_mouse_position()
	for hbox in $ScrollContainer/VBoxContainer.get_children():
		if was_any: break
		
		for but: Button in hbox.get_children():
			var pos: Vector2 = but.global_position
			var b_cms: Vector2 = but.size
			
			#print(pos.x, '<=', m_pos.x, '|', pos.y, '<=', m_pos.y, '|', pos.x + b_cms.x, '>=', m_pos.x, '|', pos.y + b_cms.y, '>=', m_pos.y)
			#print(pos.x <= m_pos.x, '|', pos.y <= m_pos.y, '|', pos.x + b_cms.x >= m_pos.x, '|', pos.y + b_cms.y >= m_pos.y)
			#print('###')
			
			if pos.x <= m_pos.x and pos.y <= m_pos.y and pos.x + b_cms.x >= m_pos.x and pos.y + b_cms.y >= m_pos.y:
				swap_from_to(but)
				
				was_any = true
				break
		
		if not was_any and false:
			# тут короче проверка, еили он конце или может в вначале уже не кнопок, а просто хбокса
			# то у проверять просто
			# а еще както сделать проверку ближайшего
			was_any = true
			break
	
	holder0 = null
	

func but_down(sender: Button) -> void:
	holder0 = but_pressed(sender)
	from = sender
	holder0.modulate.a = 0.6


func but_pressed(sender: Button) -> Button:
	var clone: Button = clone_but(sender)
	clone.position = but_m_pos(clone)
	add_child(clone)
	
	return clone


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ScrollContainer.remove_child($ScrollContainer/HFlowContainer)
	
	for stroke in strokes:
		var vcont: HBoxContainer = HBoxContainer.new()
		vcont.custom_minimum_size = Vector2(608, 32)
		vcont.add_theme_constant_override('separation', 8)
		$ScrollContainer/VBoxContainer.add_child(vcont)

		var words: PackedStringArray = stroke.split('<w///>')
		for word in words:
			word = word.replace('\n', '').strip_edges()
			
			if word != '':
				var but: Button = Button.new()
				but.text = '  ' + word + '  '
				but_add_themes(but)
				
				but.connect("button_down", func(): but_down(but))
				#but.connect("pressed", func(): but_pressed(but))
				but.connect("button_up", func(): but_up(but))
				vcont.add_child(but)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var m_pressed: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if holder0 != null and m_pressed:
		holder0.position = but_m_pos(holder0)


func _on_back_button_button_down() -> void:
	Singleton.go_to("res://scenes/work.tscn")
