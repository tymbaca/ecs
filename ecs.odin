package ecs

import "base:intrinsics"
import "base:runtime"
import "core:container/xar"

// new :: proc($STRIDE: int, allocator: runtime.Allocator) -> World(STRIDE) {
//     w: World(STRIDE)
//     return w
// }
//
// Entity :: struct {
//     id: int
//     // TODO: generation
// }
//
// World :: struct {
// 	offsets: map[typeid]int,
// 	stride:  int,
//     storage: [dynamic]u8,
// }
//
// get :: proc(w: ^World, entity: Entity, $T: typeid) -> T {
//     intrinsics.alloca()
// 	store_id := w.foo[T]
// 	store := w.component_stores[store_id]
// }
//
// set :: proc(w: ^World, entity: Entity, comp: $T) {
// }
//
// create :: proc(w: ^World) -> Entity {
//     if len(w.dead) > 0 {
//         entity := pop(w.dead)
//         entity.generation += 1
//         return entity
//     }
//
//     xar.append(&w.storage, {})
//
//     // if overflows, buffer new entities
//     // if cap(w.storage) - len(w.storage) < w.stride {
//     //    
//     // }
// }
//
// stride :: proc(types: []typeid) -> int {
//     size := 0
//     for t in types {
//         size += size_of(t)
//     }
//    
//     return size
// }
