package ecs

import "core:fmt"

LOG :: true

log :: proc(args: ..any) {
	when LOG do fmt.println(..args)
}
