package bvh

import "base:intrinsics"
import "core:mem"

Node :: struct($V, $B: typeid) {
	left:   ^Node(V, B),
	right:  ^Node(V, B),
	volume: V,
	body:   Maybe(B),
}

insert :: proc(
	this: ^Node($V, $B),
	new_volume: V,
	new_body: B,
	calculate_bounding_volume_proc: proc(a, b: V) -> V,
	get_growth_proc: proc(into, v: V) -> $N,
	arena: ^mem.Dynamic_Arena,
) where intrinsics.type_is_ordered(N) {
	if this.body != nil {
		assert(this.left == nil)
		assert(this.right == nil)

		this.left = new(Node(V, B), mem.dynamic_arena_allocator(arena))
		this.left^ = {
			volume = this.volume,
			body   = this.body,
		}

		this.right = new(Node(V, B), mem.dynamic_arena_allocator(arena))
		this.right^ = {
			volume = new_volume,
			body   = new_body,
		}

		this.body = nil
		this.volume = calculate_bounding_volume_proc(this.left.volume, this.right.volume)
		return
	}

	if this.left == nil && this.right == nil {
		// lazy init
		this.volume = new_volume
		this.body = new_body
		return
	}

	assert(this.left != nil)
	assert(this.right != nil)

	left_worth := get_growth_proc(this.left.volume, new_volume)
	right_worth := get_growth_proc(this.right.volume, new_volume)
	this_worth := get_growth_proc(this.volume, new_volume)

	if this_worth < left_worth &&
	   this_worth < right_worth &&
	   this_worth > get_growth_proc(this.left.volume, this.right.volume) {
		tmp := new(Node(V, B), mem.dynamic_arena_allocator(arena))
		tmp^ = this^
		this.left = tmp

		this.right = new(Node(V, B), mem.dynamic_arena_allocator(arena))
		this.right^ = {
			volume = new_volume,
			body   = new_body,
		}

		this.volume = calculate_bounding_volume_proc(this.left.volume, this.right.volume)
		return
	}

	if left_worth < right_worth {
		insert(
			this.left,
			new_volume,
			new_body,
			calculate_bounding_volume_proc,
			get_growth_proc,
			arena,
		)
	} else {
		insert(
			this.right,
			new_volume,
			new_body,
			calculate_bounding_volume_proc,
			get_growth_proc,
			arena,
		)
	}

	this.volume = calculate_bounding_volume_proc(this.left.volume, this.right.volume)
}
