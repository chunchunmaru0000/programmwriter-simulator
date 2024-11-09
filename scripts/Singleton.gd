extends Node

var save_file = "save.txt"
var proj: String

var hp = 1000
var hunger = 50
var thirst = 10
var sleep = 1
var time = "0:08:00"

var hunger_per_hour = 5
var thirst_per_hour = 5
var sleep_koef = 2.


var money = 500
var fridge: Array = []
var uslugi: Array = [
	Usluga.new("Водоснабжение, водоотведение", 100, "Тратится постепенно, но всегда. Обновление увеличения задолженности происходит раз в день."),
	Usluga.new("Электроснабжение", 100, "Тратится постепенно, но иногда больше. На задолженность влияет время работы за компьютером. Обновление увеличения задолженности происходит раз в день."),
	Usluga.new("Интернет от Рос*елеком", 500, "Тратится, только во время работы за компьютером. Обновление увеличения задолженности происходит в реальном времени."),
	Usluga.new("Газоснабжение, отопление", 300, "Тратится постепенно, но всегда. Обновление увеличения задолженности происходит раз в день.")
]
var ills: Dictionary = {
	'l_dehydration': Illness.new('Легкое Обезвоживание', false, 1, 
		'При продолжительной жажде возникает Легкое Обезвоживание, наносящее [color=#00cc00] Незначительный [/color] вред здоровью почасово. Возможно оно пройдет, если утолить жажду.'),
	'dehydration': Illness.new('Обезвоживание', false, 31, 
		'При долгой и продолжительной жажде возникает Обезвоживание, наносящее [color=#b30000] НАИЗНАЧИТЕЛЬНЕЙШИЙ [/color] вред здоровью почасово. Возможно оно пройдет, если утолить жажду.'),
	'l_starvation': Illness.new('Легкое Голодание', false, 1, 
		'При продолжительном голоде возникает Легкое Голодание, наносящее [color=#00cc00] Незначительный [/color] вред здоровью почасово. Возможно оно пройдет, если утолить голод.'),
	'starvation': Illness.new('Голодание', false, 3, 
		'При долгом и продолжительном голоде возникает Голодание, наносящее [color=#ff3300] Средний [/color] вред здоровью почасово. Возможно оно пройдет, если утолить голод.'),
	'l_sleep_deprivation': Illness.new('Легкий Недосып', false, 6,
		'При продолжительном отсутствии сна возникает Легкий Недосып, наносящий [color=#ff3300] Средний [/color] вред здоровью почасово. Возможно он пройдет, если достаточно поспать.'),
	'sleep_deprivation': Illness.new('Недосып', false, 62,
		'При долгом и продолжительном отсутствии сна возникает Недосып, наносящий [color=#b30000] НАИЗНАЧИТЕЛЬНЕЙШИЙ [/color] вред здоровью почасово. Возможно он пройдет, если достаточно поспать.'),
}


var task
var did_task: bool = true
var task_path: String
var slash_n: bool = true
var tabs: bool = true

var learn: bool = false


func clear() -> void:
	save_file = "save.txt"

	hp = 1000
	hunger = 50
	thirst = 10
	sleep = 1
	time = "0:08:00"
	
	money = 5000
	fridge = []

func save_progress():
	var uslugi_strs = []
	for usluga in uslugi:
		uslugi_strs.append(str(usluga.debt))
		
	var ills_strs = []
	for ill in ills:
		if ills[ill].active:
			ills_strs.append(ill)
	
	var data_str: String = "\n".join([
		"hp " + str(hp),
		"money " + str(money),
		"hunger " + str(hunger),
		"thirst " + str(thirst),
		"sleep " + str(sleep),
		"time " + str(time),
		"uslugi " + "<usluga>".join(uslugi_strs),
		"ills " + "<ill>".join(ills_strs),
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
		effects_str,
		"<sounds>".join(product.sounds)
	])
	
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	file.store_string(data_str)
	file.close()
	
func load_progress(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var lines = file.get_as_text().split('\n')	
	
	hp = int(lines[0].split(' ')[1])
	money = int(lines[1].split(' ')[1])
	hunger = int(lines[2].split(' ')[1])
	thirst = int(lines[3].split(' ')[1])
	sleep = float(lines[4].split(' ')[1])
	time = lines[5].split(' ')[1]
	
	var uslugi_strs = lines[6].split(' ')[1].split("<usluga>")
	for i in range(uslugi_strs.size()):
		uslugi[i].debt = int(uslugi_strs[i])
	
	var ills_str: String = lines[7].split(' ')[1]
	if ills_str:
		var ills_strs = ills_str.split('<ill>')
		for ill in ills_strs:
			if ill in ills:
				ills[ill].active = true
	
	var lines_was = 8
	for i in lines.size() - lines_was:
		var line_data = lines[i + lines_was].split("<product_param>")
		
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
		var effect_zip: String = line_data[11]
		var sounds: String = line_data[12]
		
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
		
		if sounds != "":
			product.sounds = sounds.split("<sounds>")
		
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
	
func add_time(to, add_sleep: bool=true) -> void:
	var hour = int(time.split(":")[1])
	var day = int(time.split(":")[0])
	hour += to
	
	if add_sleep:
		sleep += to / sleep_koef
	else:
		sleep -= to
		
	hunger += hunger_per_hour * to
	thirst += thirst_per_hour * to
	
	if hunger >= 200:
		hunger = 200
		ills['starvation'].active = true
	elif hunger >= 100:
		ills['l_starvation'].active = true
	else:
		ills['starvation'].active = false
		ills['l_starvation'].active = false
		
	if thirst >= 200:
		thirst = 200
		ills['dehydration'].active = true
	elif thirst >= 100:
		ills['l_dehydration'].active = true
	else:
		ills['dehydration'].active = false
		ills['l_dehydration'].active = false
		

	if sleep < 0:
		sleep = 0
		
	if sleep >= 40:
		sleep = 40
	
	if sleep >= 24:
		ills['sleep_deprivation'].active = true
	elif sleep >= 16:
		ills['sleep_deprivation'].active = false
		ills['l_sleep_deprivation'].active = true
	else:
		ills['sleep_deprivation'].active = false
		ills['l_sleep_deprivation'].active = false
	
		
	for i in ills:
		var ill: Illness = ills[i]
		if ill.active:
			var damage = ill.damage_per_hour * to
			hp -= damage

	# можно сделать болезни, наносят много урона в час, их нужно личить
	# если нет газа в госуслугах, следовательно холодно и следовательно: простуда и дальше пневмония
	
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
	hunger += int(to)
	
func add_thirst(to) -> void:
	thirst += int(to)
	
func add_hp(to) -> void:
	hp += to
	if hp > 1000:
		hp = 1000
	
func add_sleep(to) -> void:
	sleep += to
	if sleep < 0:
		sleep = 0
	
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
	
func go_to(path: String, save: bool=true):
	if save:
		Singleton.save_progress()
	get_tree().change_scene_to_file(path)


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
	var sounds: Array
	
	func _init(name: String, frame: int, price: float, hunger: int, thirst: int, eatings_max: int, expiration_days: int, effects: Array=[], sounds: Array=[]) -> void:
		var rnd = RandomNumberGenerator.new()
		self.name = name
		self.frame = frame
		self.hunger = hunger
		self.thirst = thirst
		self.effects = effects
		self.sounds = sounds
		
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
		
	func clone() -> Product:
		var clone: Product = Product.new(self.name, self.frame, self.price, self.hunger, self.thirst, self.eatings_max, self.expiration_days, self.effects)
		clone.price = self.price
		clone.have_discount = self.have_discount
		clone.discount = self.discount
		clone.eatings = self.eatings
		clone.expiration_hours = self.expiration_hours
		
		var effects: Array = []
		for effect in self.effects:
			var effect_clone = Effect.new(effect.name, effect.stat, effect.value)
			effects.append(effect)
		
		clone.effects = effects
		clone.sounds = [] + self.sounds

		return clone
		
		
class Usluga:
	var name: String
	var debt: float
	var desc: String
	
	func _init(name: String, debt: float, desc: String) -> void:
		self.name = name
		self.debt = debt
		self.desc = desc
		
		
class Illness:
	var name: String
	var active: bool
	var damage_per_hour: int
	var desc: String
	
	func _init(name: String, active: bool, damage_per_hour: int, desc: String) -> void:
		self.name = name
		self.active = active
		self.damage_per_hour = damage_per_hour
		self.desc = desc
