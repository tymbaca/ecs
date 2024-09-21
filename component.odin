package ecs

import "core:fmt"
import "core:reflect"
import rl "vendor:raylib"

set_component :: proc(world: ^World($Component), entity: ^Entity, component: $T) {
	component_type := typeid_of(type_of(component))

	// Init comp_map of that type if it doesn't exist
	if world.components[component_type] == nil {
		world.components[component_type] = make(map[int]Component)
	}

	// Add component to storage
	comp_map := world.components[component_type]
	comp_map[entity.id] = component
	world.components[component_type] = comp_map // in case of map evacuation

	// Set component flag on entity
	entity.components[component_type] = {}
}

must_get_component :: proc(
	w: World($Component),
	id: int,
	$T: typeid,
	loc := #caller_location,
) -> T {
	comp, ok := get_component(w, id, T)
	if !ok {
		log("MUST PANIC")
		panic(fmt.aprintf("can't get component, caller: %v", loc))
	}
	log(comp, ok)

	return comp
}

get_component :: proc(w: World($Component), id: int, $T: typeid) -> (T, bool) #optional_ok {
	component_map, ok := w.components[T]
	if !ok {
		return T{}, false
	}

	// Get union component from map
	component: Component
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
