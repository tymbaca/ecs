package ecs

import "core:fmt"

DEBUG :: false

log :: proc(args: ..any) {
    if DEBUG {
        fmt.println(..args)
    }
}
