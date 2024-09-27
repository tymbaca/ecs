package component

import "../.."
import rl "vendor:raylib"

Collider :: struct {
	colliding:      bool,
	last_collision: ecs.Entity,
	collisions:     []ecs.Entity,
	offset:         rl.Vector2,
	pivot:          Pivot,
	shape:          Shape,
}
