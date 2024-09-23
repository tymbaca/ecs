package component

import rl "vendor:raylib"

Transform :: struct {
	pos: rl.Vector2,
}

Limit_Transform :: struct {}

Simple_Gravity :: struct {
	force:    f32,
	disabled: bool,
}

Physics :: struct {
	vector:          rl.Vector2,
	mass:            f32,
	vertical_active: bool,
}
