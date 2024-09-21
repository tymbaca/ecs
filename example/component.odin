package main

import rl "vendor:raylib"

// This is user-created union type that holds all user-created components
// It will be passed on creation of ecs.World (to ecs.new_world)
Component :: union {
	Player_Control,
	Movement,
	Health,
	Platform,
	Collider,
	Gravity,
	Transform,
	Sprite,
	Box,
}

Box :: struct {
	size:  [2]i32,
	color: rl.Color,
}

Player_Control :: struct {}

Movement :: struct {
	speed: f32,
}

Health :: struct {}

Platform :: struct {}

Collider :: struct {}

Gravity :: struct {}

Transform :: struct {
	pos: rl.Vector2,
}

Sprite :: struct {}
