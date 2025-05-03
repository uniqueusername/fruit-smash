extends Node

const SETTINGS_FILE = "user://settings.cfg"

var config = ConfigFile.new()
var err = config.load(SETTINGS_FILE)

var particles = true

func _ready():
	if err != OK:
		config.set_value("graphics", "particles", particles)
		config.save(SETTINGS_FILE)
		return
	particles = config.get_value("graphics", "particles", false)




