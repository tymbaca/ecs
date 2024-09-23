package ecs

import "core:fmt"

LOG :: false

log :: proc(args: ..any, loc := #caller_location) {
	when LOG {
		fmt.print(loc)
		fmt.print(" ")
		fmt.println(..args)
	}
}
