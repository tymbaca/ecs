package colliders

import "core:math/linalg"
import ecs "../../.."
import rl "vendor:raylib"
import "core:math/rand"
import "bvh"

SCREEN_WIDTH :: 1200
SCREEN_HEIGHT :: 800

Creating :: struct {}
Ready :: struct {}

main :: proc() {
    allocator := context.allocator

    world: ecs.World
    ecs.init(&world, {Circle, Creating, Ready, rl.Color}, allocator)
    defer ecs.destroy(&world)
    w := &world
   
    ecs.register(w, spawn_system)
    ecs.register(w, delete_system)

    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "window")

    draw_depth := -1    

    for !rl.WindowShouldClose() {
        ecs.update(w)

        root: bvh.Node(Circle, struct{})
        for e in ecs.query(w, {Circle}) {
            circle := ecs.get(w, e, Circle)
            bvh.insert(&root, circle, struct{}{}, calculate_bounding_circle, get_circle_growth, &w.frame_arena)
        }

        if rl.IsKeyPressed(.UP) {
            draw_depth -= 1
            draw_depth = max(draw_depth, -1)
        }
        if rl.IsKeyPressed(.DOWN) {
            draw_depth += 1
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.DARKGRAY)

        rl.DrawRectangle(0, 0, SCREEN_WIDTH, 40, rl.BLACK);
        rl.DrawText(rl.TextFormat("depth: %i", draw_depth), 10, 10, 20, rl.GREEN)

        for e in ecs.query(w, {Circle}) {
            circle := ecs.get(w, e, Circle)
            color := ecs.get(w, e, rl.Color)
            rl.DrawCircleV(auto_cast circle.center, circle.radius, color)
        }

        draw_node(&root, rl.RED, draw_depth)

        rl.EndDrawing()
    }
}

draw_node :: proc(node: ^bvh.Node(Circle, struct{}), color: rl.Color, draw := -1, depth := 0) {
    if node == nil {
        return
    }

    if draw == -1 || draw == depth {
        rl.DrawCircleLinesV(auto_cast node.volume.center, node.volume.radius, color)
        rl.DrawText(rl.TextFormat("%i", depth), i32(node.volume.center.x), i32(node.volume.center.y), i32(node.volume.radius), rl.WHITE)
    }

    draw_node(node.left, color, draw = draw, depth = depth + 1)
    draw_node(node.right, color, draw = draw, depth = depth + 1)
}

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
            ecs.unset(w, e, Creating)
            ecs.set(w, e, Ready{})
 
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
