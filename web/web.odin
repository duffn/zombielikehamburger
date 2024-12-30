package web

import "../src"
import "base:runtime"
import "core:math/rand"
import "core:mem"
import rl "libs:raylib"

foreign import "odin_env"

ctx: runtime.Context

@(export, link_name = "game_init")
game_init :: proc "contextless" () {
	using src
	context = ctx
	init()
}

@(export, link_name = "game_update")
game_update :: proc "contextless" () {
	using src
	context = ctx
	update_draw_frame()
}

@(export, link_name = "game_dispose")
game_dispose :: proc "contextless" () {
	using src
	context = ctx
	dispose()
}
