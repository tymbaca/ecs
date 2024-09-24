package component

import "../entity"
import rl "vendor:raylib"

Collider :: struct {
	colliding:      bool,
	last_collision: entity.Entity,
	collisions:     []entity.Entity,
	offset:         rl.Vector2,
	pivot:          Pivot,
	shape:          Shape,
}
