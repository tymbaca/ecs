package examples

import ecs ".."
import "vendor:wgpu"

Position :: struct {}
Velocity :: struct {}

main :: proc() {
    world := ecs.new()
    ecs.register_component(&world, Position)
    ecs.register_component(&world, Velocity)

    ecs.register_system(&world, proc(w: ^ecs.World) {
        for entity_id in ecs.query(w, {Position, Velocity}) {
            pos := ecs.get_component(w, entity_id, Position)
            vel := ecs.get_component(w, entity_id, Velocity)




            ecs.set_component(w, entity_id, Position, pos)
            ecs.set_component(w, entity_id, Velocity, vel)
        }
    })

    ecs.register_system(&world, proc(w: ^ecs.World) {
        for entity_id in ecs.query(w, {Position, Velocity}) {
            pos := ecs.get_component(w, entity_id, Position)
            vel := ecs.get_component(w, entity_id, Velocity)




            ecs.set_component(w, entity_id, Position, pos)
            ecs.set_component(w, entity_id, Velocity, vel)
        }
    })
}


