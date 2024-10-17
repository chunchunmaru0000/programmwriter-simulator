extends Node2D


var rnd = RandomNumberGenerator.new()

var from: Button = null
var to: Button = null

func but_click() -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ScrollContainer.remove_child($ScrollContainer/HFlowContainer)
	
	var text: String = FileAccess.open("res://text_py_code.txt", FileAccess.READ).get_as_text()
	var text_bez_n = text.replace('<n///>', '')
	var strokes: PackedStringArray = text_bez_n.split('\n')
	
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
				but.add_theme_color_override("font_color",  Color("#000000"))
				but.add_theme_color_override("font_hover_color",  Color("#000000"))
				but.add_theme_color_override("font_pressed_color",  Color("#000000"))
				but.add_theme_color_override("font_focus_color",  Color("#000000"))
				
				but.add_theme_stylebox_override('hover', load("res://pc_images/vs/hover_flat.tres"))
				but.add_theme_stylebox_override('hover_pressed', load("res://pc_images/vs/hover_flat.tres"))
				but.add_theme_stylebox_override('pressed', load("res://pc_images/vs/hover_flat.tres"))
				but.add_theme_stylebox_override('focus', load("res://pc_images/vs/hover_flat.tres"))
				
				but.add_theme_stylebox_override('normal', load("res://pc_images/vs/normal_flat.tres"))
				
				vcont.add_child(but)
	
	print(123)
	pass
	#$TextEdit.remove_child($TextEdit.get_h_scroll_bar())
	#
	#
	#var dir = DirAccess.open("res://langs/" + Singleton.lang.name + "/codes")
	#var files: Array = Array(dir.get_files())
	#files.shuffle()
	#print(files)
	#print("res://langs/" + Singleton.lang.name + "/codes/" + files[0])
	#var code: Array = FileAccess.open(
		#"res://langs/" + Singleton.lang.name + "/codes/" + files[0], 
		#FileAccess.READ
	#).get_as_text().split('\n')
	#
	#if not code.size() < 22:
		#var code_new: Array = []
		#var i: int = rnd.randi_range(0, code.size() - 21)
		#for j in 21:
			#code_new.append(code[i + j])
		#code = code_new
	#
	#$TextEdit.text = '\n'.join(code)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_button_down() -> void:
	Singleton.go_to("res://scenes/work.tscn")
