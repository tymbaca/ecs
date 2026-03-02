package examples

import "core:fmt"
import "core:container/xar"
import ecs ".."

Position :: struct {
    pos: [2]f64,
}

Velocity :: struct {
    vel: [2]f64,
}

main :: proc() {
    allocator := context.allocator

    size := 0
    for t in ([]typeid{Position, Velocity}) {
        size += size_of(t)
    }

    ar: xar.Array([size]u8, 6)

    // stride := ecs.stride({Position, Velocity})
    // world := ecs.new(stride, allocator)
    //
    // fmt.println(world)
    //
    // ecs.register_system(&world, proc(w: ^ecs.World) {
    //     for entity_id in ecs.query(w, {Position, Velocity}) {
    //         pos := ecs.get(w, entity_id, Position)
    //         vel := ecs.get(w, entity_id, Velocity)
    //
    //         // is this allowed?
    //         // i think we can to this with w.arena. it will be of size `entity_count * sizeof(Entity_ID) * ??? can be specified`
    //         for another_id in ecs.query(w, {Position}) {
    //
    //         }
    //
    //         ecs.set(w, entity_id, pos)
    //         ecs.set(w, entity_id, vel)
    //     }
    // })
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


