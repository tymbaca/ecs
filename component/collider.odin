package component

import rl "vendor:raylib"

Collider :: struct {
	offset: rl.Vector2,
	pivot:  Pivot,
	shape:  Shape,
}
