package desktop

import "../src"
import "../src/config"
import rl "libs:raylib"

main :: proc() {
	using src

	rl.SetTargetFPS(config.TARGET_FPS)

	init()

	for !rl.WindowShouldClose() {
		update_draw_frame()
	}
	dispose()
}
