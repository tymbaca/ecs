package main

import ".."
import "core:fmt"
import rl "vendor:raylib"

player_movement_system :: proc(w: ^World) {
	for &e in w.entities {
		if ecs.has_components(e, PlayerControl, Movement, Transform) {
			transform := ecs.must_get_component(w^, e.id, Transform)
			movement := ecs.must_get_component(w^, e.id, Movement)

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

draw_box_system :: proc(w: ^World) {
	for &e in w.entities {
		if ecs.has_components(e, Box, Transform) { 	// maybe make combined func? that will return all needed components in place
			ecs.log("hello from draw box")

			transform := ecs.must_get_component(w^, e.id, Transform)
			box := ecs.must_get_component(w^, e.id, Box)

			rl.DrawRectangle(
				i32(transform.pos.x),
				i32(transform.pos.y),
				box.size.x,
				box.size.y,
				box.color,
			)

			ecs.set_component(w, &e, transform)
		}
	}
}
