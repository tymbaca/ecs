package entity

Entity :: struct {
	id:         int,
	components: ComponentSet,
}

ComponentSet :: map[typeid]struct {}
