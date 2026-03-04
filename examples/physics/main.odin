package main

import rl "vendor:raylib"
import "core:fmt"

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
    
    ecs.register(&world, apply_velocity)

    for _ in 0..<10000 {
        e := ecs.create(&world)
        ecs.set(&world, e, Position{10, 2})
        ecs.set(&world, e, Velocity{1, 1.4})
        ecs.set(&world, e, Circle{})
    }

    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "window")

    for {
        ecs.update(&world)

        ecs.query(&world, {Shape})
    }

}

apply_velocity :: proc(w: ^ecs.World) {
    for entity in ecs.query(w, {Position, Velocity}) {
        pos := ecs.get(w, entity, Position)
        vel := ecs.get(w, entity, Velocity)

        pos.xy += Position(vel.xy)
        fmt.println("entity", entity, "pos", pos, "vel", vel)

        ecs.set(w, entity, pos)
        ecs.set(w, entity, vel)
    }
}
