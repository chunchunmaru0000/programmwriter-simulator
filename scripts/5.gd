extends Node2D

var Effect = Singleton.Effect
var Product = Singleton.Product


var year = 365
var all_products = [
	Product.new("Гречка",        0,   36,   20,   0,    8,    year),
	Product.new("Хлеб чёрный",   1,   52,   6,    -5,   4,    4),
	Product.new("Хлеб белый",    2,   32,   5,    -5,   4,    4),
	Product.new("Чай зеленый",   3,   50,   0,    10,   10,   year, 
		[Effect.new("Бодрость", "Сон", -1)]),
	Product.new("Чай чёрный",    4,   49,   0,    10,   10,   year, 
		[Effect.new("Бодрость", "Сон", -1)]),
	Product.new("Колбаса",       5,   200,  30,   0,    7,    7),
	Product.new("Овсянка в пакетиках",
								 6,   173,  15,   0,    5,    year),
	Product.new("Квас",          7,   65,   0,    8,    10,   year, [], 
		["res://audio/putin-kvasku-to-mahnuli-uzhe-s-utra.mp3"]), 
	Product.new("Пиво",          8,   45,   0,    2,    2,    year, 
		[Effect.new("Сонность", "Сон", 1), Effect.new("Вредность", "Здоровье", -1)],
		["res://audio/piva-mnogo-pil-v-svobodnoe-vremya.mp3"]),
 	Product.new("Вобла",         9,   140,  15,   -7,   1,    year, [], 
		["res://audio/i-rybku (mp3cut.net).mp3"]),
	Product.new("Водка",         10,  249,  0,    20,   1,    year**10,
		[Effect.new("Сонность", "Сон", 4), Effect.new("Вредность", "Здоровье", -10)],
		["res://audio/vsyu-vodku-vyipit-nevozmojo-no-stremitsya-k-etomu-nado.mp3"]),
	Product.new("Сало",          11,  120,  10,   0,    2,    90, [], 
		["res://audio/putin_-zrja-vy-hrjukaete (mp3cut.net).mp3",
		 "res://audio/zelen.mp3"]),
	Product.new("Сивнина",       12,  99,   25,   0,    2,    1,  [],
		["res://audio/mjaso.mp3", "res://audio/zelen.mp3"]),
	Product.new("Кофе",          13,  208,  0,    10,   10,    year,
		[Effect.new("Бодрость", "Сон", -1)],
		["res://audio/kofe.mp3"])
]

var rnd = RandomNumberGenerator.new()
var products = []


func remove_owned_product(but: Button, product) -> void:
	if Singleton.money - product.price < 0:
		$audio.stop()
		var sounds = [
			"res://audio/biznes.mp3",
			"res://audio/gde-nashi-dengi.mp3",
			"res://audio/kot-naplakal.mp3",
			"res://audio/medvedb.mp3",
			"res://audio/sovest-est-u-vas.mp3",
			"res://audio/vyffy.mp3",
			"res://audio/vyi-rabotat-budete.mp3",
			"res://audio/nischee.mp3"
		]
		sounds.shuffle()
		$audio.stream = load(sounds[0])
		$audio.play()
	else:
		Singleton.set_money(Singleton.money - product.price)
		$money.text = "Ваши средства: " + str(Singleton.money) + " руб."
		Singleton.append_fridge(product)
		
		for i in products.size():
			if product == products[i]:
				products.remove_at(i)
				break
		
		if product.sounds.size() > 0:
			$audio.stop()
			product.sounds.shuffle()
			$audio.stream = load(product.sounds[0])
			$audio.play()	
				
		$ProductsScroll/ProductGrid.remove_child(but.get_parent())


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$money.text = "Ваши средства: " + str(Singleton.money) + " руб."
	Singleton.add_time(1)
	
	for i in rnd.randi_range(20, 100):
		products.append(all_products[rnd.randi_range(0, all_products.size() - 1)].clone())
	products.sort_custom(func (a, b): return a.price > b.price)
	
	var column_wide = 292 # 112
	
	for product in products:
		var anim = TextureRect.new()
		anim.texture = preload("res://images/products/products_anim.tres").get_frame_texture("default", product.frame)
		anim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		anim.custom_minimum_size.x = column_wide
		anim.custom_minimum_size.y = column_wide - 24 - 24
		
		
		var label = Label.new()
		if product.have_discount:
			label.text = product.name + " СКИДКА " + str(product.discount) + "%"
		else:
			label.text = product.name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		
		var color_rect = ColorRect.new()
		color_rect.custom_minimum_size = Vector2(column_wide, 24)
		color_rect.color = Color(0.2, 0.2, 0.5, 0.5)
		color_rect.add_child(label)
		
		
		var but = Button.new()
		but.text = str(product.price) + "руб."
		but.custom_minimum_size.x = column_wide
		but.custom_minimum_size.y = 24
		
		but.connect("button_down", func(): remove_owned_product(but, product))

		
		var cont = VBoxContainer.new()
		cont.add_child(anim)
		cont.add_child(color_rect)
		cont.add_child(but)
		cont.custom_minimum_size.x = column_wide
		cont.custom_minimum_size.y = column_wide
		
		$ProductsScroll/ProductGrid.add_child(cont)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	Singleton.go_to("res://scenes/game.tscn")
