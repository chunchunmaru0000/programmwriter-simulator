extends Node2D
	
	
func update_time() -> void:
	var hour = Singleton.get_hour()
	$ClockAnim.frame = hour if hour < 12 else hour - 12


func update_labels() -> void:
	$StatsHBox/Info1LabelBox/Hp.text = str(Singleton.hp)
	$StatsHBox/Info1LabelBox/Money.text = str(Singleton.money)
	$StatsHBox/Info1LabelBox/Hunger.text = str(Singleton.hunger)
	$StatsHBox/Info1LabelBox/Thirst.text = str(Singleton.thirst)
	$StatsHBox/Info1LabelBox/Sleep.text = str(Singleton.sleep)
	
	update_time()
	$Time.text = "День " + str(Singleton.get_day()) + (".5" if Singleton.get_hour() > 12 else "")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_labels()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	Singleton.go_to("res://scenes/start.tscn")


func _on_sleep_pressed() -> void:
	var sleep_time = 2
	Singleton.add_time(sleep_time)
	Singleton.add_sleep(-sleep_time * 2)

	update_labels()


func _on_gos_pressed() -> void:
	Singleton.go_to("res://scenes/gos_login.tscn")


func _on_5_pressed() -> void:
	Singleton.go_to("res://scenes/5.tscn")


func _on_work_pressed() -> void:
	Singleton.go_to("res://scenes/desktop.tscn")


func _on_fridge_pressed() -> void:
	Singleton.go_to("res://scenes/fridge.tscn")
