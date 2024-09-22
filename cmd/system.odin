package main

import ".."
import "core:fmt"
import "core:time"
import rl "vendor:raylib"

empty_system :: proc(w: ^ecs.World) {
	for &e in w.entities {
		if ecs.has_components(e, ecs.Transform) {
			transform := ecs.must_get_component(w^, e.id, ecs.Transform)
			_ = transform

			// do something
		}
	}
}

stress_test_system :: proc(w: ^ecs.World) {
	time.sleep(10 * time.Millisecond)
}

spawn_systems :: proc(system: ecs.System, count: int) -> []ecs.System {
	systems := make([dynamic]ecs.System, count)

	for i in 0 ..< count {
		systems[i] = system
	}

	return systems[:]
}

player_movement_system :: proc(w: ^ecs.World) {
	for &e in w.entities {
		if ecs.has_components(e, ecs.Player_Control, ecs.Movement, ecs.Transform) {
			transform := ecs.must_get_component(w^, e.id, ecs.Transform)
			movement := ecs.must_get_component(w^, e.id, ecs.Movement)

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

draw_sprite_system :: proc(w: ^ecs.World) {
	for &e in w.entities {
		if ecs.has_components(e, ecs.Sprite, ecs.Transform) {
			transform := ecs.must_get_component(w^, e.id, ecs.Transform)
			sprite := ecs.must_get_component(w^, e.id, ecs.Sprite)

			rl.DrawTextureEx(
				sprite.texture,
				{transform.pos.x, transform.pos.y},
				0,
				sprite.scale,
				rl.WHITE,
			)

			ecs.set_component(w, &e, transform)
		}
	}
}

apply_gravity_system :: proc(w: ^ecs.World) {
	for &e in w.entities {
		if ecs.has_components(e, ecs.Gravity, ecs.Physics) {
			physics := ecs.must_get_component(w^, e.id, ecs.Physics)
			gravity := ecs.must_get_component(w^, e.id, ecs.Gravity)

			physics.vector.y += gravity.force

			ecs.set_component(w, &e, physics)
		}
	}
}

draw_physics_vector_system :: proc(w: ^ecs.World) {
	for &e in w.entities {
		if ecs.has_components(e, ecs.Gravity, ecs.Physics) {
			physics := ecs.must_get_component(w^, e.id, ecs.Physics)
			gravity := ecs.must_get_component(w^, e.id, ecs.Gravity)


		}
	}
}


apply_physics_system :: proc(w: ^ecs.World) {
	for &e in w.entities {
		if ecs.has_components(e, ecs.Gravity, ecs.Physics) {
			physics := ecs.must_get_component(w^, e.id, ecs.Physics)
			transform := ecs.must_get_component(w^, e.id, ecs.Transform)

			if !physics.vertical_active do transform.pos.y = 0

			transform.pos += physics.vector

			ecs.set_component(w, &e, transform)
		}
	}
}
