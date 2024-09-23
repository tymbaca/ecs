package component

import rl "vendor:raylib"

ComponentStorage :: map[typeid]map[int]Component

Component :: union {
	Player_Control,
	Movement,
	Health,
	Collider,
	Simple_Gravity,
	Physics,
	Transform,
	Limit_Transform,
	Sprite,
	Jump,
}
