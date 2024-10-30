extends Node2D


class LangData:
	var exp: int
	var slash_n: bool
	var tabs: bool
	
	func _init(exp: int, slash_n: bool, tabs: bool) -> void:
		self.exp = exp
		self.slash_n = slash_n
		self.tabs = tabs


class Lang:
	var name: String
	var img: String
	var codes_paths: Array
	var learn_paths: Array
	var data: LangData
	
	func _init(name: String, img: String, codes_paths: Array, learn_paths: Array, data: LangData) -> void:
		self.name = name
		self.img = img
		self.codes_paths = codes_paths
		self.learn_paths = learn_paths
		self.data = data


var langs_names: PackedStringArray = DirAccess.open("res://langs/").get_directories()
var langs: Array = []


func get_datas_from_langs() -> void:
	if langs.size() == 0:
		for lang_name in langs_names:
			var lang_path: String = "res://langs/" + lang_name + "/"
			var codes_path: String = lang_path + "codes/"
			var learn_path: String = lang_path + "learn/"
			
			var data_text = FileAccess.open(lang_path + "data.txt", FileAccess.READ).get_as_text().split('\n')
			print(data_text[1].split('=')[1].strip_edges())
			var lang_data: LangData = LangData.new(
				int(data_text[0].split('=')[1].strip_edges()),
				data_text[1].split('=')[1].strip_edges() == '1',
				data_text[2].split('=')[1].strip_edges() == '1'
			)
			
			var lang: Lang = Lang.new(
				lang_name,
				lang_path + "logo.png",
				Array(DirAccess.open(codes_path).get_files()).map(func(s): return codes_path + s),
				Array(DirAccess.open(learn_path).get_files()).map(func(s): return learn_path + s),
				lang_data
			)
			
			print(lang.name)
			print('exp=', lang_data.exp, ';slash_n=', lang_data.slash_n, ';tabs=', lang_data.tabs)
			print(lang.codes_paths)
			print(lang.learn_paths)
			langs.append(lang)


func draw_learn() -> void:
	$Background.texture = load("res://pc_images/chrome/learn/back.png")
	for child in $Scroll/Lenta.get_children():
		$Scroll/Lenta.remove_child(child)
		child.queue_free()
	
	
	

func draw_money() -> void:
	$Background.texture = load("res://pc_images/chrome/money/back.png")
	for child in $Scroll/Lenta.get_children():
		$Scroll/Lenta.remove_child(child)
		child.queue_free()
	
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_datas_from_langs()
	var times = Singleton.time.split(':')
	$Time.text = times[1] + ':' + times[2]
	
	if Singleton.learn:
		$LearnBut.grab_focus()
		draw_learn()
	else:
		$MoneyBut.grab_focus()
		draw_money()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_down() -> void:
	Singleton.go_to("res://scenes/game.tscn")


func _on_vs_button_down() -> void:
	Singleton.go_to("res://scenes/visual_studio.tscn")


func _on_esc_but_button_down() -> void:
	Singleton.go_to("res://scenes/desktop.tscn")


func _on_money_but_button_down() -> void:
	Singleton.learn = false
	draw_money()


func _on_learn_but_button_down() -> void:
	Singleton.learn = true
	draw_learn()
