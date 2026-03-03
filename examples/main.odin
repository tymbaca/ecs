package examples

import "core:time"
import "core:fmt"
import ecs ".."

Position :: distinct [2]f64
Velocity :: distinct [2]f64

main :: proc() {
    allocator := context.allocator

    world: ecs.World
    ecs.init(&world, allocator, {Position, Velocity})
    
    ecs.register(&world, proc(w: ^ecs.World) {
        for entity in ecs.query(w, {Position, Velocity}) {
            pos := ecs.get(w, entity, Position)
            vel := ecs.get(w, entity, Velocity)
    
            pos += Position(vel)
            fmt.println("entity", entity, "pos", pos, "vel", vel)
    
            ecs.set(w, entity, pos)
            ecs.set(w, entity, vel)
        }
    })

    for _ in 0..<100 {
        e := ecs.create(&world)
        ecs.set(&world, e, Position{10, 20})
    }

    for {
        time.sleep(time.Second)
        ecs.update(&world)
    }
    
    // get_ptr is rejected
    //
    // ecs.register_system(&world, proc(w: ^ecs.World) {
    //     for entity_id in ecs.query(w, {Position, Velocity}) {
    //         pos := ecs.get_ptr(w, entity_id, Position)
    //         vel := ecs.get_ptr(w, entity_id, Velocity)
    //
    //         pos^ += vel^
    //     }
    // })
    //
    // ecs.register_system(&world, proc(w: ^ecs.World) {
    //     for entity_id in ecs.query(w, {Position, Velocity}) {
    //         pos := ecs.get_ptr(w, entity_id, Position)
    //         vel := ecs.get_ptr(w, entity_id, Velocity)
    //
    //
    //         // HERE happens reallocation - pos and vel will be invalid
    //         // maybe use exponential arrays for components. YES
    //         // nope, xar needs comptime size of stride and that is a bit ugly
    //         // create entity will be buffered and applyed at the end of frame
    //         id := ecs.create(w)
    //         ecs.set(w, id, Position{10, 20})
    //         // ...
    //     }
    // })
}


