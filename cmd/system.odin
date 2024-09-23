package main

import ".."
import "core:fmt"
import "core:time"
import rl "vendor:raylib"

DEBUG :: true

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

			origin := origin_by_pivot(transform.pos + sprite.offset, sprite.size, sprite.pivot)

			rl.DrawTexturePro(
				sprite.texture,
				full_texture_rect(sprite.texture),
				{origin.x, origin.y, sprite.size.x, sprite.size.y},
				{},
				0,
				rl.WHITE,
			)
			/*
			rl.DrawTextureEx(
				sprite.texture,
				{transform.pos.x, transform.pos.y},
				0,
				sprite.scale,
				rl.WHITE,
			)
            */

			ecs.set_component(w, &e, transform)
		}
	}
}

full_texture_rect :: proc(texture: $T) -> rl.Rectangle {
	return {0, 0, f32(texture.width), f32(texture.height)}
}

COLLIDER_DEBUG_COLOR :: rl.Color{0, 121, 241, 100}

debug_collider_shapes :: proc(w: ^ecs.World) {
	when !DEBUG do return
	for &e in w.entities {
		if ecs.has_components(e, ecs.Transform, ecs.Collider) {
			transform := ecs.must_get_component(w^, e.id, ecs.Transform)
			collider := ecs.must_get_component(w^, e.id, ecs.Collider)

			switch shape in collider.shape {
			case ecs.Box:
				origin := transform.pos + collider.offset
				origin = origin_by_pivot(origin, shape.size, collider.pivot)
				rl.DrawRectangle(
					i32(origin.x),
					i32(origin.y),
					i32(shape.size.x),
					i32(shape.size.y),
					COLLIDER_DEBUG_COLOR,
				)
			}
		}
	}
}

origin_by_pivot :: proc(origin, size: rl.Vector2, pivot: ecs.Pivot) -> rl.Vector2 {
	origin := origin

	switch pivot {
	case .Upper_Left:
		return origin
	case .Center:
		return origin - size / 2
	case .Down:
		origin.x -= size.x / 2
		origin.y -= size.y
		return origin
	}

	return origin
}

TRANSFORM_COLOR :: rl.Color{241, 120, 60, 170}

debug_transform :: proc(w: ^ecs.World) {
	when !DEBUG do return
	for &e in w.entities {
		if ecs.has_components(e, ecs.Transform) {
			transform := ecs.must_get_component(w^, e.id, ecs.Transform)

			ecs.log("debug transform", transform)
			rl.DrawCircleV(transform.pos, 6, TRANSFORM_COLOR)
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

limit_transform_in_screen_system :: proc(w: ^ecs.World) {
	for &e in w.entities {
		if ecs.has_components(e, ecs.Transform, ecs.Limit_Transform) {
			transform := ecs.must_get_component(w^, e.id, ecs.Transform)

			transform.pos.x = rl.Clamp(transform.pos.x, 0, f32(SCREEN.x))
			transform.pos.y = rl.Clamp(transform.pos.y, 0, f32(SCREEN.y))

			ecs.set_component(w, &e, transform)
		}
	}
}
