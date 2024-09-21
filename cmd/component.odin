package main

import rl "vendor:raylib"

Component :: union {
	int,
	PlayerControl,
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

PlayerControl :: struct {}

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
