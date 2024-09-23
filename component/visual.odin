package component

import rl "vendor:raylib"

Sprite :: struct {
	texture: rl.Texture,
	size:    rl.Vector2,
	pivot:   Pivot,
	offset:  rl.Vector2,
}

// Where the Transform will be relative to object that has pivot setting
Pivot :: enum {
	Upper_Left = 0,
	Center,
	Down,
}
