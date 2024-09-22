extends Node

var save_file = "save.txt"

var hp = 1000
var hunger = 50
var thirst = 10
var sleep = 1
var time = "0:08:00"

var money = 5000
var fridge: Array = []

func save_progress():
	var data_str: String = "\n".join([
		"hp " + str(hp),
		"money " + str(money),
		"hunger " + str(hunger),
		"thirst " + str(thirst),
		"sleep " + str(sleep),
		"time " + str(time)
	])
	for product in fridge:
		var effects_str: String
		match product.effects.size():
			0:
				effects_str = ""
			1:
				var effect = product.effects[0]
				effects_str = effect.name + "<effect_param>" + effect.stat + "<effect_param>" + str(effect.value)
			_:
				var effects_strs: Array = []
				for effect in product.effects:
					effects_strs.append("<effect_param>".join([
						effect.name,
						effect.stat,
						str(effect.value)
					]))
				effects_str = "<effects>".join(effects_strs)
		
		
		data_str += "\n" + "<product_param>".join([
		product.name,
		str(product.frame),
		str(product.price),
		str(product.hunger),
		str(product.thirst),
		str(1 if product.have_discount else 0),
		str(product.discount),
		str(product.expiration_days),
		str(product.expiration_hours),
		str(product.eatings_max),
		str(product.eatings),
		effects_str
	])
	
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	file.store_string(data_str)
	file.close()
	
func load_progress(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var lines = file.get_as_text().split('\n')
	
	hp = lines[0].split(' ')[1]
	money = lines[1].split(' ')[1]
	hunger = lines[2].split(' ')[1]
	thirst = lines[3].split(' ')[1]
	sleep = lines[4].split(' ')[1]
	time = lines[5].split(' ')[1]
	
	for i in lines.size() - 6:
		var line_data = lines[i + 6].split("<product_param>")
		
		var name: String = line_data[0]
		var frame: String = line_data[1]
		var price: String = line_data[2]
		var hunger: String = line_data[3]
		var thirst: String = line_data[4]
		var have_discount: String = line_data[5]
		var discount: String = line_data[6]
		var expiration_days: String = line_data[7]
		var expiration_hours: String = line_data[8]
		var eatings_max: String = line_data[9]
		var eatings: String = line_data[10]
		var effect_zip :String = line_data[11]
		
		
		var product = Product.new(name, int(frame), float(price), int(hunger), int(thirst), int(eatings_max), int(expiration_days))
		product.price = price
		product.have_discount = true if have_discount == "1" else false
		product.discount = discount
		product.eatings = eatings
		product.expiration_hours = expiration_hours
		
		if effect_zip != "":
			var effects = []
			
			for effect_str in effect_zip.split("<effects>"):
				var effect_params: Array = effect_str.split("<effect_param>")
				var effect: Effect = Effect.new(effect_params[0], effect_params[1], effect_params[2])
				effects.append(effect)
				
			product.effects = effects
		
		fridge.append(product)

func set_save_file(to) -> void:
	save_file = to

func set_hp(to) -> void:
	hp = int(to)

func set_hunger(to) -> void:
	hunger = int(to)

func set_thirst(to) -> void:
	thirst = int(to)
	
func set_sleep(to) -> void:
	sleep = int(to)
	
func set_money(to) -> void:
	money = int(to)
	
func set_time(to) -> void:
	time = to
	
func add_time(to) -> void:
	var hour = int(time.split(":")[1])
	var day = int(time.split(":")[0])
	hour += to
	sleep += to
	
	while hour >= 24:
		hour -= 24
		day += 1
		
	time = str(day) + ":" + str(hour) + ":00"
	
	for product in fridge:	
		(product as Product).expiration_hours -= to
		while product.expiration_hours < 0:
			product.expiration_hours += 24
			product.expiration_days -= 1
		
		if (product.expiration_hours == 0 and product.expiration_days == 0) or product.expiration_days < 0:
			remove_fridge_at(get_product_index(product))
	
func add_hunger(to) -> void:
	hunger += to
	
func add_thirst(to) -> void:
	thirst += to
	
func add_hp(to) -> void:
	hp += to
	
func add_sleep(to) -> void:
	sleep += to
	
func get_hour() -> int:
	return int(time.split(":")[1])
	
func get_day() -> int:
	return int(time.split(":")[0])
	
func get_product_index(product) -> int:
	for i in fridge.size():
		if product == fridge[i]:
			return i
	return -1
	
func append_fridge(product) -> void:
	fridge.append(product)
	
func remove_fridge_at(index: int) -> void:
	fridge.remove_at(index)
	
func remove_fridge(product) -> void:
	remove_fridge_at(get_product_index(product))

func set_fridge_at(index: int, product: Product) -> void:
	fridge[index] = product


class Effect:
	var name: String
	var stat: String
	var value
	
	func _init(name: String, stat: String, value) -> void:
		self.name = name
		self.stat = stat
		self.value = value


class Product:
	var name: String
	var frame: int
	var price: float
	var hunger: int
	var thirst: int
	var have_discount: bool
	var discount: float
	var expiration_days: int
	var expiration_hours: int
	var eatings_max: int
	var eatings: int
	var effects: Array
	
	func _init(name: String, frame: int, price: float, hunger: int, thirst: int, eatings_max: int, expiration_days: int, effects: Array=[]) -> void:
		var rnd = RandomNumberGenerator.new()
		self.name = name
		self.frame = frame
		self.hunger = hunger
		self.thirst = thirst
		self.effects = effects
		
		self.have_discount = rnd.randi_range(0, 100) < 5
		self.discount = rnd.randi_range(-3, 10) * 5
		if self.have_discount:
			self.price = price / 100 * (100 - discount)
		else:
			self.price = price
		if self.discount <= 0:
			self.discount = rnd.randi_range(5, 10) * 5
		
		self.expiration_days = expiration_days
		self.expiration_hours = 0
		self.eatings_max = eatings_max
		self.eatings = eatings_max
		
