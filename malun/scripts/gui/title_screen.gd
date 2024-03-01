extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _on_settings_pressed():
	hide_all()
	$SettingsWindow.visible = !$SettingsWindow.visible
func _on_open_server_pressed():
	hide_all()
	$ServerWindow.visible = !$ServerWindow.visible
func _on_open_client_pressed():
	hide_all()
	$ClientWindow.visible = !$ClientWindow.visible

func hide_all():
	$SettingsWindow.visible = false
	$ServerWindow.visible = false
	$ClientWindow.visible = false

func _on_client_name_text_changed(new_text):
	Data.multidata["name"] = new_text
func _on_server_name_text_changed(new_text):
	Data.multidata["name"] = new_text
func _on_address_text_changed(new_text):
	Data.MULTI_ADDRESS = new_text
