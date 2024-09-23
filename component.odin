package ecs

import cmp "component"
import "core:fmt"
import "core:reflect"

set_component :: proc {
	set_component_union,
}

// set_component created of replaces (if it already exists) the component on the entity.
set_component_union :: proc(world: ^World, entity: ^Entity, component: cmp.Component) {
	component_type := reflect.union_variant_typeid(component)

	// Init comp_map of that type if it doesn't exist
	if world.components[component_type] == nil {
		world.components[component_type] = make(map[int]cmp.Component)
	}

	// Add component to storage
	comp_map := world.components[component_type]
	comp_map[entity.id] = component
	world.components[component_type] = comp_map // in case of map evacuation

	// Set component flag on entity
	entity.components[component_type] = {}
}

get_component :: proc(w: World, id: int, $T: typeid) -> (T, bool) #optional_ok {
	component_map, ok := w.components[T]
	if !ok {
		return T{}, false
	}

	// Get union component from map
	component: cmp.Component
	component, ok = component_map[id]
	if !ok {
		return T{}, false
	}

	// Convert component to concrete type
	final_component: T
	final_component, ok = component.(T)
	assert(
		ok,
		fmt.aprintf(
			"got incorrent component type (%v) in map of type %T",
			reflect.union_variant_typeid(component),
			T{},
		),
	)

	return final_component, true
}

// `must_get_component` is the same as `get_component` but it panics if not found
must_get_component :: proc(w: World, id: int, $T: typeid, loc := #caller_location) -> T {
	comp, ok := get_component(w, id, T)
	if !ok {
		panic(fmt.aprintf("can't get component, caller: %v", loc))
	}

	return comp
}
