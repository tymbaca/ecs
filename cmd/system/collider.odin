package system

import cmp "../component"

COLLISION_TRESHOLD :: 5 // move to collision_system

colliding_bottom :: proc(col: cmp.Collider) -> bool {
	return true
}
