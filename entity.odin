package ecs

import "base:intrinsics"
import "core:fmt"
import "core:reflect"

// Entity represents the Entity :) It holds it's ID and flags of 
// components that it has
Entity :: struct {
	id:         int,
	components: ComponentSet,
}

// ComponentSet is a set of flags of component types that entity owns
ComponentSet :: map[typeid]struct {}

new_entity :: proc() -> Entity {
	@(static)id := 0
	id += 1
	e := Entity {
		id         = id,
		components = make(ComponentSet),
	}

	return e
}

has_components :: proc(e: Entity, types: ..typeid) -> bool {
	for t in types {
		if t not_in e.components {
			return false
		}
	}

	return true
}

// create_entity creates new entity with specified components, adds it to world and returns it
create_entity :: proc {
	create_entity_slice,
	create_entity_0,
	create_entity_1,
	create_entity_2,
	create_entity_3,
	create_entity_4,
	create_entity_5,
	create_entity_6,
	create_entity_7,
	create_entity_8,
	create_entity_9,
	create_entity_10,
}

create_entity_slice :: proc(
	world: ^World($T),
	components: []T,
) -> Entity where intrinsics.type_is_union(T) {
	e := new_entity()

	for comp in components {
		set_component(world, &e, comp)
	}

	append(&world.entities, e)

	return e
}

create_entity_0 :: proc(world: ^World($T)) -> Entity {
	return create_entity_slice(world, []T{})
}

create_entity_1 :: proc(world: ^World($T), cmp1: T) -> Entity {
	return create_entity_slice(world, []T{cmp1})
}

create_entity_2 :: proc(world: ^World($T), cmp1, cmp2: T) -> Entity {
	return create_entity_slice(world, []T{cmp1, cmp2})
}

create_entity_3 :: proc(world: ^World($T), cmp1, cmp2, cmp3: T) -> Entity {
	return create_entity_slice(world, []T{cmp1, cmp2, cmp3})
}

create_entity_4 :: proc(world: ^World($T), cmp1, cmp2, cmp3, cmp4: T) -> Entity {
	return create_entity_slice(world, []T{cmp1, cmp2, cmp3, cmp4})
}

create_entity_5 :: proc(world: ^World($T), cmp1, cmp2, cmp3, cmp4, cmp5: T) -> Entity {
	return create_entity_slice(world, []T{cmp1, cmp2, cmp3, cmp4, cmp5})
}

create_entity_6 :: proc(world: ^World($T), cmp1, cmp2, cmp3, cmp4, cmp5, cmp6: T) -> Entity {
	return create_entity_slice(world, []T{cmp1, cmp2, cmp3, cmp4, cmp5, cmp6})
}

create_entity_7 :: proc(world: ^World($T), cmp1, cmp2, cmp3, cmp4, cmp5, cmp6, cmp7: T) -> Entity {
	return create_entity_slice(world, []T{cmp1, cmp2, cmp3, cmp4, cmp5, cmp6, cmp7})
}

create_entity_8 :: proc(
	world: ^World($T),
	cmp1, cmp2, cmp3, cmp4, cmp5, cmp6, cmp7, cmp8: T,
) -> Entity {
	return create_entity_slice(world, []T{cmp1, cmp2, cmp3, cmp4, cmp5, cmp6, cmp7, cmp8})
}

create_entity_9 :: proc(
	world: ^World($T),
	cmp1, cmp2, cmp3, cmp4, cmp5, cmp6, cmp7, cmp8, cmp9: T,
) -> Entity {
	return create_entity_slice(world, []T{cmp1, cmp2, cmp3, cmp4, cmp5, cmp6, cmp7, cmp8, cmp9})
}

create_entity_10 :: proc(
	world: ^World($T),
	cmp1, cmp2, cmp3, cmp4, cmp5, cmp6, cmp7, cmp8, cmp9, cmp10: T,
) -> Entity {
	return create_entity_slice(
		world,
		[]T{cmp1, cmp2, cmp3, cmp4, cmp5, cmp6, cmp7, cmp8, cmp9, cmp10},
	)
}
