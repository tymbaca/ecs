package system

import "../.."
import cmp "../component"
import "core:fmt"
import "core:time"
import rl "vendor:raylib"

DEBUG :: true

World :: ecs.World(cmp.Component)

empty_system :: proc(w: ^World) {
	for &e in w.entities {
		if ecs.has_components(e, cmp.Transform) {
			transform := ecs.must_get_component(w^, e.id, cmp.Transform)
			_ = transform

			// do something
		}
	}
}

stress_test_system :: proc(w: ^World) {
	time.sleep(10 * time.Millisecond)
}

/*
spawn_systems :: proc(system: ecs.System, count: int) -> []ecs.System {
	systems := make([dynamic]ecs.System, count)

	for i in 0 ..< count {
		systems[i] = system
	}

	return systems[:]
}
*/

draw_sprite_system :: proc(w: ^World) {
	for &e in w.entities {
		if ecs.has_components(e, cmp.Sprite, cmp.Transform) {
			transform := ecs.must_get_component(w^, e.id, cmp.Transform)
			sprite := ecs.must_get_component(w^, e.id, cmp.Sprite)

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

debug_collider_shapes :: proc(w: ^World) {
	when !DEBUG do return
	for &e in w.entities {
		if ecs.has_components(e, cmp.Transform, cmp.Collider) {
			transform := ecs.must_get_component(w^, e.id, cmp.Transform)
			collider := ecs.must_get_component(w^, e.id, cmp.Collider)

			switch shape in collider.shape {
			case cmp.Box:
				rl.DrawRectangleRec(
					rect_by_pivot(transform.pos + collider.offset, shape.size, collider.pivot),
					COLLIDER_DEBUG_COLOR,
				)
			}
		}
	}
}

origin_by_pivot :: proc(origin, size: rl.Vector2, pivot: cmp.Pivot) -> rl.Vector2 {
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

rect_by_pivot :: proc(origin, size: rl.Vector2, pivot: cmp.Pivot) -> rl.Rectangle {
	newOrigin := origin_by_pivot(origin, size, pivot)
	return {newOrigin.x, newOrigin.y, size.x, size.y}
}

TRANSFORM_COLOR :: rl.Color{241, 120, 60, 170}

debug_transform :: proc(w: ^World) {
	when !DEBUG do return
	for &e in w.entities {
		if ecs.has_components(e, cmp.Transform) {
			transform := ecs.must_get_component(w^, e.id, cmp.Transform)

			ecs.log("debug transform", transform)
			rl.DrawCircleV(transform.pos, 6, TRANSFORM_COLOR)
		}
	}
}

draw_physics_vector_system :: proc(w: ^World) {
	for &e in w.entities {
		if ecs.has_components(e, cmp.Simple_Gravity, cmp.Physics) {
			physics := ecs.must_get_component(w^, e.id, cmp.Physics)
			gravity := ecs.must_get_component(w^, e.id, cmp.Simple_Gravity)

			// TODO
		}
	}
}

player_movement_system :: proc(w: ^World) {
	for &e in w.entities {
		if ecs.has_components(e, cmp.Player_Control, cmp.Movement, cmp.Transform) {
			transform := ecs.must_get_component(w^, e.id, cmp.Transform)
			movement := ecs.must_get_component(w^, e.id, cmp.Movement)

			diff: rl.Vector2

			/*
			if rl.IsKeyDown(.W) {
				diff.y -= movement.speed
			}
			if rl.IsKeyDown(.S) {
				diff.y += movement.speed
			}
            */
			if rl.IsKeyDown(.A) {
				diff.x -= movement.speed
			}
			if rl.IsKeyDown(.D) {
				diff.x += movement.speed
			}

			transform.pos += diff * w.delta

			ecs.set_component(w, &e, transform)
		}
	}
}

apply_gravity_system :: proc(w: ^World) {
	for &e in w.entities {
		if ecs.has_components(e, cmp.Simple_Gravity, cmp.Transform) {
			transform := ecs.must_get_component(w^, e.id, cmp.Transform)
			gravity := ecs.must_get_component(w^, e.id, cmp.Simple_Gravity)

			transform.pos.y += gravity.force * w.delta

			ecs.set_component(w, &e, transform)
		}
	}
}

jump_system :: proc(w: ^World) {
	for &e in w.entities {
		if ecs.has_components(e, cmp.Simple_Gravity, cmp.Transform, cmp.Jump) {
			transform := ecs.must_get_component(w^, e.id, cmp.Transform)
			jump := ecs.must_get_component(w^, e.id, cmp.Jump)
			gravity := ecs.must_get_component(w^, e.id, cmp.Simple_Gravity)
			collider := ecs.must_get_component(w^, e.id, cmp.Collider)

			if rl.IsKeyDown(.SPACE) && !jump.busy && colliding_bottom(collider) {
				jump.busy = true
				jump.current_velocity = jump.power
				gravity.disabled = true
			}

			if jump.current_velocity <= 0 {
				jump.busy = false // BUG, can do multiple jumps without landing
				gravity.disabled = false
			} else {
				jump.current_velocity -= jump.falloff * w.delta
				transform.pos.y -= jump.current_velocity * w.delta
			}

			ecs.set_component(w, &e, transform)
			ecs.set_component(w, &e, jump)
			ecs.set_component(w, &e, gravity)
		}
	}
}


limit_transform_in_screen_system :: proc(w: ^World) {
	for &e in w.entities {
		if ecs.has_components(e, cmp.Transform, cmp.Limit_Transform) {
			transform := ecs.must_get_component(w^, e.id, cmp.Transform)
			limit := ecs.must_get_component(w^, e.id, cmp.Limit_Transform)

			transform.pos.x = rl.Clamp(transform.pos.x, limit.min_x, limit.max_x)
			transform.pos.y = rl.Clamp(transform.pos.y, limit.min_y, limit.max_y)

			ecs.set_component(w, &e, transform)
		}
	}
}

collision_system :: proc(w: ^World) {
	for &e in w.entities {
		if ecs.has_components(e, cmp.Transform, cmp.Limit_Transform) {
			transform := ecs.must_get_component(w^, e.id, cmp.Transform)

			ecs.set_component(w, &e, transform)
		}
	}
}
