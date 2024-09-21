package main

import ".."
import "core:fmt"
import rl "vendor:raylib"

player_movement_system :: proc(w: ^ecs.World) {
	for &e in w.entities {
		if ecs.has_components(e, ecs.PlayerControl, ecs.Movement, ecs.Transform) {
			transform := ecs.get_component(w^, e.id, ecs.Transform)
			movement := ecs.get_component(w^, e.id, ecs.Movement)

			if rl.IsKeyDown(.W) {
				transform.pos.y -= movement.speed
			}
			if rl.IsKeyDown(.S) {
				transform.pos.y += movement.speed
			}
			if rl.IsKeyDown(.A) {
				transform.pos.x -= movement.speed
			}
			if rl.IsKeyDown(.D) {
				transform.pos.x += movement.speed
			}

			ecs.set_component(w, &e, transform)
		}
	}
}
