extends Node2D

var but_height = 24
var anim_wide = 112
var mini_wide = 24
var anim_height = anim_wide
var cont_wide = 632 - 8
var info_wide = cont_wide - anim_wide
var rnd = RandomNumberGenerator.new()


class Lang:
	var name: String
	var img: String
	var desc: String
	var exp: int
	
	func _init(name: String, img: String, desc: String, exp: int=0) -> void:
		self.name = name
		self.img = img
		self.desc = desc
		self.exp = exp
		
		
class Task:
	var task: String
	var money
	var desc: String
	var img: String
	
	func _init(task: String, money: int, desc: String, img: String) -> void:
		var rnd = RandomNumberGenerator.new()
		self.task = task
		var m = money * 0.1
		self.money = money + rnd.randi_range(-m, m)
		self.desc = desc
		self.img = img
		
	func clone():
		var t: Task = Task.new(self.task, self.money, self.desc, self.img)
		t.money = self.money
		return t
		
		
var all_tasks = [
	Task.new(
		"Починить код", 1000, 
		"Некий код был частично утерян и требуется восстановление, некоторые части кода известны, что облегчает задачу", 
		"res://images/work/images.jpg"
	),
	Task.new(
		"Дописать код", 1500, 
		"Некий код был частично утерян и требуется восстановление, утерянные части кода не известны, что усложняет задачу", 
		"res://images/work/write.png"
	),
]

var dir = DirAccess.open("res://langs")
var langs_names: PackedStringArray = dir.get_directories()
var langs: Array = []


func clear_LangBox() -> void:
	for child in $LangsScroll/LangBox.get_children():
		$LangsScroll/LangBox.remove_child(child)
		child.queue_free()


func re_ready() -> void:
	$BackButton.disconnect("button_down", re_ready)
	$BackButton.connect("button_down", _on_back_button_button_down)
	clear_LangBox()
	_ready()


func choose_level(current_lang: Lang) -> void:
	$BackButton.disconnect("button_down", _on_back_button_button_down)
	$BackButton.connect("button_down", re_ready)
	clear_LangBox()

	var tasks = []
	
	for i in rnd.randi_range(5, 15):
		tasks.append(all_tasks[rnd.randi_range(0, all_tasks.size() - 1)].clone())
	
	
	for task in tasks:
		var eat_but = Button.new()
		eat_but.text = task.task + ", Цена: " + str(task.money) # Выбрать " + str(i) + " сложность"
		eat_but.custom_minimum_size.x = cont_wide
		eat_but.custom_minimum_size.y = but_height + but_height
		eat_but.connect("button_down", func():
			Singleton.lang = current_lang
			Singleton.task = task
			Singleton.go_to("res://scenes/visual_studio.tscn")
		)
		
		var butsBox = HBoxContainer.new()
		butsBox.custom_minimum_size.x = cont_wide
		butsBox.custom_minimum_size.y = but_height + but_height
		butsBox.add_child(eat_but)
		
		var text_butsBox = VBoxContainer.new()
		text_butsBox.custom_minimum_size.x = cont_wide
		text_butsBox.custom_minimum_size.y = but_height + but_height
		text_butsBox.add_child(butsBox)
		
		var anim = TextureRect.new()
		anim.texture = load(task.img)
		anim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		anim.custom_minimum_size.x = anim_wide
		anim.custom_minimum_size.y = anim_height
		
		var info = Label.new()
		info.custom_minimum_size.x = info_wide
		info.custom_minimum_size.y = anim_height
		#info.text = "\n".join(descs[i - 1].split(' '))
		info.text = task.desc
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		var info_rect = ColorRect.new()
		info_rect.custom_minimum_size.x = info_wide - 8
		info_rect.custom_minimum_size.y = anim_height
		info_rect.color = Color(0.2, 0.2, 0.5, 0.5)
		info_rect.add_child(info)
		
		var infoCont = ScrollContainer.new()
		infoCont.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		infoCont.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
		infoCont.custom_minimum_size.x = info_wide
		infoCont.custom_minimum_size.y = anim_height
		infoCont.add_child(info_rect)
		
		var anim_infoBox = HBoxContainer.new()
		anim_infoBox.custom_minimum_size.x = cont_wide
		anim_infoBox.custom_minimum_size.y = anim_wide
		anim_infoBox.add_child(anim)
		anim_infoBox.add_child(infoCont)
		
		var mainBox = VBoxContainer.new()
		mainBox.custom_minimum_size.x = cont_wide
		mainBox.custom_minimum_size.y = anim_height + but_height + but_height
		mainBox.add_child(anim_infoBox)
		mainBox.add_child(text_butsBox)
		
		$LangsScroll/LangBox.add_child(mainBox)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if langs.size() == 0:
		for lang_name in langs_names:
			var lang_path: String = "res://langs/" + lang_name + "/"
			langs.append(Lang.new(
				lang_name,
				lang_path + "logo.png",
				FileAccess.open(lang_path + "desc.txt", FileAccess.READ).get_as_text(),
				int(FileAccess.open(lang_path + "data.txt", FileAccess.READ).get_as_text())
			))
	
	for lang in langs:
		var garbage_but = Button.new()
		garbage_but.text = "Учить"
		garbage_but.custom_minimum_size.x = anim_height
		garbage_but.custom_minimum_size.y = but_height
		garbage_but.connect("button_down", func(): pass)
		
		var eat_but = Button.new()
		eat_but.text = "Работать"
		eat_but.custom_minimum_size.x = cont_wide - anim_height
		eat_but.custom_minimum_size.y = but_height
		eat_but.connect("button_down", func(): choose_level(lang as Lang))
		
		var butsBox = HBoxContainer.new()
		butsBox.custom_minimum_size.x = cont_wide
		butsBox.custom_minimum_size.y = but_height + but_height
		butsBox.add_child(eat_but)
		butsBox.add_child(garbage_but)
		
		var expr = Label.new()
		expr.text = "Ваш опыт: " + str(lang.exp) # + " дней " + str(product.expiration_hours) + " часов"
		var expr_rect = ColorRect.new()
		expr_rect.custom_minimum_size = Vector2(cont_wide, but_height)
		expr_rect.color = Color(0.0, 0.2, 0.0, 0.35)
		expr_rect.add_child(expr)
		
		var text_butsBox = VBoxContainer.new()
		text_butsBox.custom_minimum_size.x = cont_wide
		text_butsBox.custom_minimum_size.y = but_height + but_height
		text_butsBox.add_child(expr_rect)
		text_butsBox.add_child(butsBox)
		
		
		var anim = TextureRect.new()
		anim.texture = load(lang.img)
		anim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		anim.custom_minimum_size.x = anim_wide
		anim.custom_minimum_size.y = anim_height
		
		var info = Label.new()
		info.custom_minimum_size.x = info_wide
		info.custom_minimum_size.y = anim_height
		#info.text = "\n".join(descs[i - 1].split(' '))
		info.text = lang.desc
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		var info_rect = ColorRect.new()
		info_rect.custom_minimum_size.x = info_wide - 8
		info_rect.custom_minimum_size.y = 200
		info_rect.color = Color(0.0, 0.2, 0.0, 0.35)
		info_rect.add_child(info)
		
		var infoCont = ScrollContainer.new()
		infoCont.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		infoCont.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
		infoCont.custom_minimum_size.x = info_wide
		infoCont.custom_minimum_size.y = anim_height
		infoCont.add_child(info_rect)
		
		var anim_infoBox = HBoxContainer.new()
		anim_infoBox.custom_minimum_size.x = cont_wide
		anim_infoBox.custom_minimum_size.y = anim_wide
		anim_infoBox.add_child(anim)
		anim_infoBox.add_child(infoCont)
		
		var mainBox = VBoxContainer.new()
		mainBox.custom_minimum_size.x = cont_wide
		mainBox.custom_minimum_size.y = anim_height + but_height + but_height
		mainBox.add_child(anim_infoBox)
		mainBox.add_child(text_butsBox)
		
		$LangsScroll/LangBox.add_child(mainBox)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_button_down() -> void:
	Singleton.go_to("res://scenes/game.tscn")
