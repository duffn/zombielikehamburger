package main

import "base:runtime"
import "core:fmt"
import "core:mem"
import rl "libs:raylib"

import "config"
import "entities"
import "screens"

g: entities.Game
main_arena: mem.Arena
main_data: [mem.Megabyte * 20]byte
temp_allocator: mem.Scratch_Allocator

IS_WEB :: ODIN_ARCH == .wasm32 || ODIN_ARCH == .wasm64p32


init :: proc() {
	context = runtime.default_context()

	when ODIN_DEBUG && !IS_WEB {
		rl.SetTraceLogLevel(.DEBUG)

		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	} else {
		rl.SetTraceLogLevel(.ERROR)
	}

	when IS_WEB {
		mem.arena_init(&main_arena, main_data[:])
		context.allocator = mem.arena_allocator(&main_arena)

		mem.scratch_allocator_init(&temp_allocator, mem.Megabyte * 2)
		context.temp_allocator = mem.scratch_allocator(&temp_allocator)
	}

	rl.InitWindow(config.SCREEN_WIDTH, config.SCREEN_HEIGHT, "Zombie Like Hamburger")

	rl.InitAudioDevice()
	g.music = rl.LoadMusicStream("assets/sounds/music.mp3")
	rl.SetMusicVolume(g.music, 0.75)
	rl.PlayMusicStream(g.music)

	screens.init_title_screen(&g)
	g.current_screen = .TITLE

	defer delete(g.people)
	defer delete(g.roads)
	defer delete(g.cars)

	for !rl.WindowShouldClose() {
		update_draw_frame()
	}

	// TODO: remove all partials
	#partial switch g.current_screen {
	case .TITLE:
		screens.unload_title_screen()
	case .INSTRUCTIONS:
		screens.unload_instructions_screen()
	case .GAMEPLAY:
		screens.unload_gameplay_screen(&g)
	}
}


dispose :: proc() {
	rl.UnloadMusicStream(g.music)

	rl.CloseAudioDevice()
	rl.CloseWindow()
}


transition_to_screen :: proc(screen: entities.GameScreen) {
	g.transition = entities.Transition {
		on_transition     = true,
		trans_fade_out    = false,
		trans_from_screen = g.current_screen,
		trans_to_screen   = screen,
		trans_alpha       = 0.0,
	}
}


update_transition :: proc() {
	if !g.transition.trans_fade_out {
		g.transition.trans_alpha += 0.02
		if g.transition.trans_alpha > 1.01 {
			g.transition.trans_alpha = 1.0
			// Unload old screen
			#partial switch g.transition.trans_from_screen {
			case .TITLE:
				screens.unload_title_screen()
			case .INSTRUCTIONS:
				screens.unload_instructions_screen()
			case .GAMEPLAY:
				screens.unload_gameplay_screen(&g)
			}

			// Init the new screen
			#partial switch g.transition.trans_to_screen {
			case .TITLE:
				screens.init_title_screen(&g)
			case .INSTRUCTIONS:
				screens.init_instructions_screen(&g)
			case .GAMEPLAY:
				screens.init_gameplay_screen(&g)
			}

			g.current_screen = g.transition.trans_to_screen
			g.transition.trans_fade_out = true
		}
	} else {
		g.transition.trans_alpha -= 0.02
		if g.transition.trans_alpha < -0.01 {
			g.transition.trans_alpha = 0.0
			g.transition.trans_fade_out = false
			g.transition.on_transition = false
			g.transition.trans_from_screen = .NONE
			g.transition.trans_to_screen = .NONE
		}
	}
}


draw_transition :: proc() {
	rect := rl.Rectangle{0, 0, f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}
	rl.DrawRectangleRec(rect, rl.Fade(rl.BLACK, g.transition.trans_alpha))
}


change_to_screen :: proc(screen: entities.GameScreen) {
	// Unload current
	#partial switch g.current_screen {
	case .TITLE:
		screens.unload_title_screen()
	case .INSTRUCTIONS:
		screens.unload_instructions_screen()
	case .GAMEPLAY:
		screens.unload_gameplay_screen(&g)
	}

	// Init new
	#partial switch screen {
	case .TITLE:
		screens.init_title_screen(&g)
	case .INSTRUCTIONS:
		screens.init_instructions_screen(&g)
	case .GAMEPLAY:
		screens.init_gameplay_screen(&g)
	}

	g.current_screen = screen
}


update_draw_frame :: proc() {
	dt := rl.GetFrameTime()

	rl.UpdateMusicStream(g.music)

	if !g.transition.on_transition {
		#partial switch g.current_screen {
		case .TITLE:
			screens.update_title_screen(dt, &g)
			#partial switch screens.finish_title_screen(&g) {
			case .INSTRUCTIONS:
				transition_to_screen(.INSTRUCTIONS)
			case .GAMEPLAY:
				transition_to_screen(.GAMEPLAY)
			}

		case .INSTRUCTIONS:
			screens.update_instructions_screen(dt, &g)
			#partial switch screens.finish_instructions_screen(&g) {
			case .TITLE:
				transition_to_screen(.TITLE)
			case .GAMEPLAY:
				transition_to_screen(.GAMEPLAY)
			}

		case .GAMEPLAY:
			screens.update_gameplay_screen(dt, &g)
			#partial switch screens.finish_gameplay_screen(&g) {
			case .TITLE:
				transition_to_screen(.TITLE)
			case .GAMEPLAY:
				transition_to_screen(.GAMEPLAY)
			}
		}
	} else {
		update_transition()
	}

	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)

	#partial switch g.current_screen {
	case .TITLE:
		screens.draw_title_screen()
	case .INSTRUCTIONS:
		screens.draw_instructions_screen(&g)
	case .GAMEPLAY:
		screens.draw_gameplay_screen(&g)
	}

	if g.transition.on_transition {
		draw_transition()
	}

	rl.EndDrawing()
}
