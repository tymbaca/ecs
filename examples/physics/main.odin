package main

import "core:log"
import "core:time"
import rl "vendor:raylib"
import "core:math/rand"

import ecs "../.."

Position :: distinct [2]f32
Velocity :: distinct [2]f32
Shape :: union {
    Circle,
}

Circle :: struct {
    radius: f32,
    color:  rl.Color
}

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600

main :: proc() {
    allocator := context.allocator

    world: ecs.World
    ecs.init(&world, {Position, Velocity, Shape}, allocator)
    defer ecs.destroy(&world)
    w := &world
    
    ecs.register(w, apply_velocity)

    for _ in 0..<100000 {
        e := ecs.create(w)
        ecs.set(w, e, Position{SCREEN_WIDTH/2, SCREEN_HEIGHT/2})
        ecs.set(w, e, Velocity{rand_f32(), rand_f32()})
        ecs.set(w, e, Shape(Circle{
            radius = 20,
            color = rl.ORANGE,
        }))
    }

    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "window")

    for !rl.WindowShouldClose() {
        ecs.update(w)

        rl.BeginDrawing()
        rl.ClearBackground(rl.GRAY)

        render_start := time.tick_now()
        draw_circle_dur: time.Duration

        drawed := 0
        query := ecs.query(w, {Position, Shape})
        for e in query {
            pos := ecs.get(w, e, Position)
            if pos.x > SCREEN_WIDTH/2 - 20 && pos.x < SCREEN_WIDTH/2 + 20 {
                switch shape in ecs.get(w, e, Shape) {
                case Circle:
                    draw_circle_one_start := time.tick_now()
                    rl.DrawCircleV(auto_cast pos, shape.radius, shape.color)
                    draw_circle_dur += time.tick_since(draw_circle_one_start)
                    drawed += 1
                }
            }
        }

        ecs.log("circles drawen:", drawed)
        if drawed > 0 {
            ecs.log("avg DrawCircleV time:", draw_circle_dur / auto_cast drawed)
        }
        ecs.log("render time:", time.tick_since(render_start))

        rl.DrawFPS(10, 10)

        rl.EndDrawing()
    }

}

apply_velocity :: proc(w: ^ecs.World) {
    for entity in ecs.query(w, {Position, Velocity}) {
        pos := ecs.get(w, entity, Position)
        vel := ecs.get(w, entity, Velocity)

        pos.xy += Position(vel.xy)

        switch pos.x {

        }
        if pos.x < 0 || pos.x > SCREEN_WIDTH || pos.y < 0 || pos.y > SCREEN_HEIGHT {
            ecs.kill(w, entity)
        }

        ecs.set(w, entity, pos)
        ecs.set(w, entity, vel)
    }
}

rand_f32 :: proc() -> f32 {
    return rand.float32() * 2 - 1
}
