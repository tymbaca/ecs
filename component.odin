package ecs

import "core:fmt"
import "core:reflect"
import rl "vendor:raylib"

set_component :: proc {
	set_component_union,
}

// set_component created of replaces (if it already exists) the component on the entity.
set_component_union :: proc(world: ^World, entity: ^Entity, component: Component) {
	component_type := reflect.union_variant_typeid(component)

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

get_component :: proc(w: World, id: int, $T: typeid) -> (T, bool) #optional_ok {
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

// must_get_component is the same as get_component but it panics if not found
must_get_component :: proc(w: World, id: int, $T: typeid, loc := #caller_location) -> T {
	comp, ok := get_component(w, id, T)
	if !ok {
		panic(fmt.aprintf("can't get component, caller: %v", loc))
	}

	return comp
}


ComponentStorage :: map[typeid]map[int]Component

Component :: union {
	Player_Control,
	Movement,
	Health,
	Platform,
	Collider,
	Gravity,
	Physics,
	Air_Resistance,
	Transform,
	Limit_Transform,
	Sprite,
}

Player_Control :: struct {}

Movement :: struct {
	speed: f32,
}

Health :: struct {}

Platform :: struct {}

Collider :: struct {
	offset: rl.Vector2,
	pivot:  Pivot,
	shape:  Shape,
}

Gravity :: struct {
	force: f32,
}

Physics :: struct {
	vector:          rl.Vector2,
	mass:            f32,
	vertical_active: bool,
}

Air_Resistance :: struct {
	force: f32,
}

Transform :: struct {
	pos: rl.Vector2,
}

Limit_Transform :: struct {}

Sprite :: struct {
	texture: rl.Texture,
	size:    rl.Vector2,
	pivot:   Pivot,
	offset:  rl.Vector2,
}

Box :: struct {
	size: rl.Vector2,
}

Shape :: union {
	Box,
}

// Where the Transform will be relative to object that has pivot setting
Pivot :: enum {
	Upper_Left,
	Center,
	Down,
}
