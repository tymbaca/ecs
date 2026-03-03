package ecs

import "base:intrinsics"
import "base:runtime"
import "core:mem"
import "core:strings"

World :: struct {
	offsets:     map[typeid]int,
	storage:     [dynamic]u8,
	freelist:    [dynamic]Entity,
	systems:     [dynamic]System,
	stride:      int,
	next_id:     int,
	frame_arena: mem.Dynamic_Arena,
	allocator:   runtime.Allocator,
	userdata:    rawptr,
	// TODO:
	// delta_time:  time.Duration,
}

Entity :: struct {
	id:         int,
	generation: int,
}

System :: #type proc(w: ^World)

init :: proc(w: ^World, types: []typeid, allocator: runtime.Allocator) {
	w.offsets = make(map[typeid]int, allocator)
	w.storage = make([dynamic]u8, allocator)
	w.systems = make([dynamic]System, allocator)
	mem.dynamic_arena_init(&w.frame_arena, allocator, allocator)

	size := size_of(Block_Header)
	for t in types {
		w.offsets[t] = size
		log("offset of", t, "is", size)
		size += mem.align_forward_int(size_of(Component_Header), type_info_of(t).align)
		size += type_info_of(t).size
	}

	w.stride = size
	return
}

reserve :: proc(w: ^World, entity_count: int) {
    if cap(w.storage) < (entity_count * w.stride) {
        resize(&w.storage, entity_count * w.stride)
    }
}

destroy :: proc(w: ^World) {
	delete(w.offsets)
	delete(w.storage)
	delete(w.systems)
    mem.dynamic_arena_destroy(&w.frame_arena)
}

update :: proc(w: ^World) {
	for system in w.systems {
		mem.dynamic_arena_reset(&w.frame_arena)
		system(w)
	}
}

register :: proc(w: ^World, system: System) {
	append(&w.systems, system)
}

kill :: proc(w: ^World, entity: Entity) {
	append(&w.freelist, entity) // TODO: duplicate detection?
}

create :: proc(w: ^World) -> Entity {
	if len(w.freelist) > 0 {
		entity := pop(&w.freelist)
		entity.generation += 1

		header := (^Block_Header)(&w.storage[entity.id * w.stride])
		header.entity = entity

		return entity
	}

	// resize if needed
	if len(w.storage) < w.next_id * w.stride + w.stride {
		resize(&w.storage, w.next_id * w.stride + w.stride)
	}

	entity := Entity {
		id         = w.next_id,
		generation = 0,
	}
	w.next_id += 1

	header := (^Block_Header)(&w.storage[entity.id * w.stride])
	header.entity = entity

	return entity
}

set :: proc(w: ^World, entity: Entity, component: $T) -> bool {
	header := (^Block_Header)(&w.storage[entity.id * w.stride])
	assert(header.entity.id == entity.id)

	if entity.generation < header.entity.generation {
		return false
	}

	cmp := (^Component(T))(&w.storage[entity.id * w.stride + w.offsets[T]])
	cmp.header.set = true
	cmp.component = component

	return true
}

get :: proc(w: ^World, entity: Entity, $T: typeid) -> (T, bool) #optional_ok {
	header := (^Block_Header)(&w.storage[entity.id * w.stride])
	assert(header.entity.id == entity.id)

	if entity.generation < header.entity.generation {
		return {}, false
	}

	cmp := (^Component(T))(&w.storage[entity.id * w.stride + w.offsets[T]])
	return cmp.component, cmp.header.set
}

query :: proc(w: ^World, types: []typeid) -> []Entity {
	result := make([dynamic]Entity, mem.dynamic_arena_allocator(&w.frame_arena))

	id := 0
	outter: for entity in _iterate(w, &id) {
		for t in types {
			if !_has(w, entity.id, t) {
				continue outter
			}
		}

		append(&result, entity)
	}

	return result[:]
}

@(private)
_iterate :: proc(w: ^World, id: ^int) -> (Entity, bool) {
	if id^ >= w.next_id {
		return {}, false
	}

	header := (^Block_Header)(&w.storage[id^ * w.stride])
	id^ += 1

	return header.entity, true
}

@(private)
_has :: proc(w: ^World, entity_id: int, T: typeid) -> bool {
	cmp_header := (^Component_Header)(&w.storage[entity_id * w.stride + w.offsets[T]])
	return cmp_header.set
}

@(private)
Block_Header :: struct {
	entity: Entity,
}

@(private)
Component_Header :: struct {
	set: bool,
}

@(private)
Component :: struct($T: typeid) {
	header:    Component_Header,
	component: T,
}
