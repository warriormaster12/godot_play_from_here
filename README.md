# Godot Play From Here plugin

A plugin that brings "Play from here" feature from Unreal Engine into Godot Engine.

## How to install
1. Download a zip file or clone the project.
2. Extract the zip file and move the addons/play_from_here directory into the project root location.
3. Enable the plugin inside Project/Project Settings/Plugins.

## Setup

Add following code to the script that is your player:

```
extends CharacterBody3D
class_name PlayerController

func capture_data_from_editor(message: String, data: Array) -> bool:
	match message:
		"SetPlayFromHereTransform":
			var camera_transform: Transform3D = data[0]
			global_position = camera_transform.origin
			rotation.y = camera_transform.basis.get_euler().y
		_:
			push_warning("Unknown debugger message '%s'" % [message])
			return false
	return true

func _enter_tree() -> void:
	PlayFromHere.setup(capture_data_from_editor)
```

## Features
1. Spawn player from editor camera's position.
2. Spawn player from arbitrarily selected point.

## Current limitations
There's currently no 2D support. This is due to the plugin being developed for my projects' first, most of which are in 3D. However, PR's are welcome :)
