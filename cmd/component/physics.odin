package component

import rl "vendor:raylib"

Transform :: struct {
	pos: rl.Vector2,
}

Limit_Transform :: struct {
	min_x, max_x: f32,
	min_y, max_y: f32,
}

Simple_Gravity :: struct {
	force:    f32,
	disabled: bool,
}

Physics :: struct {
	vector:          rl.Vector2,
	mass:            f32,
	vertical_active: bool,
}
