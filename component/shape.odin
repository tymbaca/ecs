package component

import rl "vendor:raylib"

Box :: struct {
	size: rl.Vector2,
}

Shape :: union {
	Box,
}
