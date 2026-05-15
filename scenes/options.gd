extends Control

# This links your nodes to the code
@onready var volume_settings = $VBoxContainer/Options/VolumeSettings
@onready var volume_on_icon = $VBoxContainer/Options/VolumeSettings/VolumeOn
@onready var volume_mute_icon = $VBoxContainer/Options/VolumeSettings/VolumeMute

func _on_options_pressed():
	# When Options is clicked, show the icons
	volume_settings.visible = !volume_settings.visible
	# Start with the "On" icon visible and "Mute" hidden
	volume_on_icon.visible = true
	volume_mute_icon.visible = false

func _on_volume_on_pressed():
	# Switch to mute icon and mute audio
	volume_on_icon.visible = false
	volume_mute_icon.visible = true
	AudioServer.set_bus_mute(0, true)

func _on_volume_mute_pressed():
	# Switch back to on icon and unmute audio
	volume_on_icon.visible = true
	volume_mute_icon.visible = false
	AudioServer.set_bus_mute(0, false)
