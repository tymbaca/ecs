package ecs

import "base:intrinsics"
MAX_ENTITIES :: 100000

World :: struct($T: typeid) where intrinsics.type_is_enum(T) {
    components: [T]u8,
}
