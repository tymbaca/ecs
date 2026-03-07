package colliders

import "core:fmt"
import "core:log"
import "core:math/linalg"
import ecs "../../.."
import rl "vendor:raylib"
import "core:math/rand"
import "bvh"

SCREEN_WIDTH :: 1200
SCREEN_HEIGHT :: 800

Creating :: struct {}
Ready :: struct {}
Velocity :: distinct [2]f32

main :: proc() {
    allocator := context.allocator

    world: ecs.World
    ecs.init(&world, {Circle, Velocity, Creating, Ready, rl.Color}, allocator)
    defer ecs.destroy(&world)
    w := &world
   
    ecs.register(w, spawn_system)
    ecs.register(w, delete_system)
    ecs.register(w, velocity_system)
    ecs.register(w, gravity_system)

    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "window")

    draw_depth := -1    

    for !rl.WindowShouldClose() {
        ecs.update(w)

        circles := ecs.query(w, {Circle})
        root: bvh.Node(Circle, ecs.Entity)
        for e in circles {
            bvh.insert(&root, ecs.get(w, e, Circle), e, calculate_bounding_circle, get_circle_growth, &w.frame_arena)
        }

        collisions, total_checks := bvh.check_collisions(&root, circles_intersect, &w.frame_arena)

        for col in collisions {
            // col.a.volume.center
            if !ecs.has(w, col.a.body, Ready) || !ecs.has(w, col.b.body, Ready) {
                continue
            }

            if !ecs.has(w, col.a.body, Velocity) || !ecs.has(w, col.b.body, Velocity) {
                continue
            }
            
            vel_a := ecs.get(w, col.a.body, Velocity)
            vel_b := ecs.get(w, col.b.body, Velocity)

            vel_a, vel_b = bounce(col.a.volume, vel_a, col.b.volume, vel_b)

            ecs.set(w, col.a.body, vel_a)
            ecs.set(w, col.b.body, vel_b)
        }

        if rl.IsKeyPressed(.UP) {
            draw_depth -= 1
            draw_depth = max(draw_depth, -2)
        }
        if rl.IsKeyPressed(.DOWN) {
            draw_depth += 1
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.DARKGRAY)

        rl.DrawRectangle(0, 0, SCREEN_WIDTH, 40, rl.BLACK);
        rl.DrawText(rl.TextFormat("depth: %i", draw_depth), 10, 10, 20, rl.GREEN)
        rl.DrawText(rl.TextFormat("collisions: %i", len(collisions)), 120, 10, 20, rl.GREEN)
        rl.DrawText(rl.TextFormat("checks: %i", total_checks), 320, 10, 20, rl.GREEN)
        rl.DrawText(rl.TextFormat("count: %i", len(circles)), 470, 10, 20, rl.GREEN)

        for e in circles {
            circle := ecs.get(w, e, Circle)
            color := ecs.get(w, e, rl.Color)
            rl.DrawCircleV(auto_cast circle.center, circle.radius, color)
        }

        draw_node(&root, rl.RED, draw_depth)

        rl.EndDrawing()
    }
}

draw_node :: proc(node: ^bvh.Node(Circle, $B), color: rl.Color, draw := -1, depth := 0) {
    if node == nil {
        return
    }

    if draw != -2 {
        if draw == -1 || draw == depth {
            rl.DrawCircleLinesV(auto_cast node.volume.center, node.volume.radius, color)
            rl.DrawText(rl.TextFormat("%i", depth), i32(node.volume.center.x), i32(node.volume.center.y), i32(node.volume.radius), rl.WHITE)
        }
    }

    draw_node(node.left, color, draw = draw, depth = depth + 1)
    draw_node(node.right, color, draw = draw, depth = depth + 1)
}

SPAWN_SPEED :: 1

spawn_system :: proc(w: ^ecs.World) {
    if rl.IsMouseButtonPressed(.LEFT) {
        e := ecs.create(w)
        ecs.set(w, e, Circle{
            center = auto_cast rl.GetMousePosition(),
            radius = 0,
        })
        ecs.set(w, e, Creating{})
        ecs.set(w, e, choose([]rl.Color{rl.ORANGE, rl.YELLOW, rl.GREEN, rl.BLUE, rl.RED, rl.PURPLE, rl.PINK}))
    }

    for e in ecs.query(w, {Circle, Creating}) {
        circle := ecs.get(w, e, Circle)
        circle.radius = linalg.distance(circle.center, auto_cast rl.GetMousePosition())
        ecs.set(w, e, circle)
    }

    if rl.IsMouseButtonUp(.LEFT) {
        for e in ecs.query(w, {Circle, Creating}) {
            circle := ecs.get(w, e, Circle)
            dir := linalg.normalize0(rl.GetMousePosition() - auto_cast circle.center)
            ecs.unset(w, e, Creating)
            ecs.set(w, e, Ready{})
            ecs.set(w, e, Velocity(dir * SPAWN_SPEED))
        }
    }
}

choose :: proc(s: $T/[]$E) -> E {
    return s[rand.int_range(0, len(s))]
}

delete_system :: proc(w: ^ecs.World) {
    if rl.IsKeyPressed(.K) {
        for e in ecs.query(w, {}) {
            ecs.kill(w, e)
        }
    }
}

velocity_system :: proc(w: ^ecs.World) {
    for e in ecs.query(w, {Circle, Velocity, Ready}) {
        circle := ecs.get(w, e, Circle)
        vel := ecs.get(w, e, Velocity)

        circle.center += auto_cast vel * w.delta

        pos := circle.center
        if (pos.x <= 0 && vel.x < 0) || (pos.x >= SCREEN_WIDTH && vel.x > 0) {
            vel.x = -vel.x
            vel *= 0.9
        }
        if (pos.y <= 0 && vel.y < 0) || (pos.y >= SCREEN_HEIGHT && vel.y > 0) {
            vel.y = -vel.y
            vel *= 0.9
        }
        // circle.center.x = min(circle.center.x, SCREEN_WIDTH-circle.radius)
        // circle.center.x = max(circle.center.x, 0+circle.radius)
        // circle.center.y = min(circle.center.y, SCREEN_HEIGHT-circle.radius)
        // circle.center.y = max(circle.center.y, 0+circle.radius)

        ecs.set(w, e, circle)
        ecs.set(w, e, vel)
    }
}

GRAVITY :: Velocity{0, 0.01}

gravity_system :: proc(w: ^ecs.World) {
    for e in ecs.query(w, {Circle, Velocity, Ready}) {
        circle := ecs.get(w, e, Circle)
        vel := ecs.get(w, e, Velocity)

        if circle.center.y+circle.radius < SCREEN_HEIGHT {
            vel += GRAVITY * w.delta
            ecs.set(w, e, vel)
        }
    }
}
