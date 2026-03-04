package examples

import "core:time"
import "core:fmt"
import ecs ".."

Position :: distinct [2]f32
Velocity :: distinct [2]f32
Circle :: struct {
    radius: f32,
}

main :: proc() {
    allocator := context.allocator

    world: ecs.World
    ecs.init(&world, {Position, Velocity, Circle}, allocator)
    
    ecs.register(&world, proc(w: ^ecs.World) {
        for entity in ecs.query(w, {Position, Velocity}) {
            pos := ecs.get(w, entity, Position)
            vel := ecs.get(w, entity, Velocity)
            // vel := Velocity{1, 1.4}
    
            pos.xy += Position(vel.xy)
            fmt.println("entity", entity, "pos", pos, "vel", vel)
    
            ecs.set(w, entity, pos)
            ecs.set(w, entity, vel)
        }
    })

    for _ in 0..<10 {
        e := ecs.create(&world)
        ecs.set(&world, e, Position{10, 2})
        ecs.set(&world, e, Velocity{1, 1.4})
    }

    for {
        time.sleep(time.Second)
        ecs.update(&world)
    }
}
