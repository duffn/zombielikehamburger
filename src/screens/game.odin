package screens

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "libs:raylib"

import "../config"
import "../entities"


GameplayText :: struct {
	button_font:         rl.Font,
	font:                rl.Font,
	font_size:           int, // = 48
	start_text:          cstring, // = "Play Again"
	start_text_position: rl.Vector2,
	start_text_size:     rl.Vector2,
	back_text:           cstring, // = "Back"
	back_text_position:  rl.Vector2,
	back_text_size:      rl.Vector2,
	button_font_size:    f32, // = 36
}

@(private = "file")
background_color: rl.Color = {95, 115, 73, 255}
@(private = "file")
text: GameplayText


init_gameplay_screen :: proc(g: ^entities.Game) {
	rl.SetMouseCursor(.DEFAULT)

	g.finish_screen = .NONE
	g.is_game_over = false
	g.score = 0

	clear(&g.people)
	clear(&g.roads)
	clear(&g.cars)

	text = GameplayText {
		button_font         = rl.LoadFontEx("assets/fonts/GeosansLight.ttf", 96, nil, 0),
		font                = rl.LoadFontEx("assets/fonts/bloody.ttf", 96, nil, 0),
		font_size           = 48,
		start_text          = "Play Again",
		start_text_position = rl.Vector2{0, 0},
		start_text_size     = rl.Vector2{0, 0},
		back_text           = "Back",
		back_text_position  = rl.Vector2{0, 0},
		back_text_size      = rl.Vector2{0, 0},
		button_font_size    = 36,
	}

	entities.road_init()
	entities.cow_init()
	entities.obstruction_init()
	entities.person_init(g)
	entities.zombie_init(g)
	entities.car_init()

	text.start_text_size = rl.MeasureTextEx(
		text.button_font,
		text.start_text,
		text.button_font_size,
		1.0,
	)
	text.start_text_position = {
		(f32(rl.GetScreenWidth()) - text.start_text_size.x) / 2.0,
		(f32(rl.GetScreenHeight()) - text.start_text_size.y) / 2.0 + 125,
	}
	text.back_text_size = rl.MeasureTextEx(
		text.button_font,
		text.back_text,
		text.button_font_size,
		1.0,
	)
	text.back_text_position = {
		(f32(rl.GetScreenWidth()) - text.back_text_size.x) / 2.0,
		(f32(rl.GetScreenHeight()) - text.back_text_size.y) / 2.0 + 175,
	}

	rl.GenTextureMipmaps(&text.font.texture)
	rl.SetTextureFilter(text.font.texture, .POINT)

	used_x_positions := make([dynamic]f32)
	defer delete(used_x_positions)

	entities.roads_place(g, &used_x_positions)
	entities.zombie_randomly_place(&g.zombie, used_x_positions)
	entities.cars_place(g)
	entities.cow_randomly_place(g)
	entities.people_place(g)
	entities.obstructions_place(g)
}


update_gameplay_screen :: proc(dt: f32, g: ^entities.Game) {
	mouse_position := rl.GetMousePosition()
	g.zombie.is_moving = false

	if !g.is_game_over {
		old_zombie_x := g.zombie.position.x
		old_zombie_y := g.zombie.position.y

		entities.zombie_update(&g.zombie, dt)
		entities.obstruction_update(g, old_zombie_x, old_zombie_y)
		entities.car_update(g, dt)
		entities.cow_update(g)
		entities.person_update(g, dt)
		entities.zombie_update_pulse_timer(&g.zombie, dt)
	} else {
		// Game over here, so show the navigation buttons
		// Start button
		start_rect := rl.Rectangle {
			text.start_text_position.x,
			text.start_text_position.y,
			text.start_text_size.x,
			text.start_text_size.y,
		}
		if rl.CheckCollisionPointRec(mouse_position, start_rect) {
			rl.SetMouseCursor(.POINTING_HAND)
			if rl.IsMouseButtonPressed(.LEFT) {
				g.finish_screen = .GAMEPLAY
			}
		}

		// Back button
		back_rect := rl.Rectangle {
			text.back_text_position.x,
			text.back_text_position.y,
			text.back_text_size.x,
			text.back_text_size.y,
		}
		if rl.CheckCollisionPointRec(mouse_position, back_rect) {
			rl.SetMouseCursor(.POINTING_HAND)
			if rl.IsMouseButtonPressed(.LEFT) {
				g.finish_screen = .TITLE
			}
		}
	}
}


draw_gameplay_screen :: proc(g: ^entities.Game) {
	rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), background_color)

	entities.road_draw(g.roads)
	entities.cow_draw(g.cows)
	entities.obstruction_draw(g.obstructions)
	entities.person_draw(g.people)
	entities.car_draw(g.cars)

	if ODIN_DEBUG {
		rl.DrawRectangleLines(
			i32(g.zombie.position.x),
			i32(g.zombie.position.y),
			i32(g.zombie.width),
			i32(g.zombie.height),
			rl.RED,
		)
	}

	entities.zombie_draw(g.zombie)

	if !g.is_game_over {
		score_text := fmt.ctprintf("Hamburger: %d", g.score)
		score_font_size: f32 = 24
		rl.DrawTextEx(
			text.font,
			score_text,
			rl.Vector2{10, 10},
			score_font_size,
			1.0,
			{255, 0, 0, 255},
		)
	}

	if g.is_game_over {
		game_over_text: cstring = "Zombie Die"
		final_score_text := fmt.ctprintf("Hamburger Eaten: %d", g.score)

		big_font_size: f32 = 60.0

		over_size := rl.MeasureTextEx(text.font, game_over_text, big_font_size, 1.0)
		score_size := rl.MeasureTextEx(text.font, final_score_text, big_font_size, 1.0)

		center_x := f32(rl.GetScreenWidth()) * 0.5
		center_y := f32(rl.GetScreenHeight()) * 0.5

		rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.Color{0, 0, 0, 180})

		rl.DrawTextEx(
			text.font,
			game_over_text,
			rl.Vector2{center_x - over_size.x * 0.5, center_y - over_size.y - 100},
			big_font_size,
			1.0,
			rl.RED,
		)
		rl.DrawTextEx(
			text.font,
			final_score_text,
			rl.Vector2{center_x - score_size.x * 0.5, center_y + score_size.y * 0.1 - 100},
			big_font_size,
			1.0,
			rl.WHITE,
		)
		rl.DrawTextEx(
			text.button_font,
			text.start_text,
			text.start_text_position,
			text.button_font_size,
			1.0,
			rl.WHITE,
		)
		rl.DrawTextEx(
			text.button_font,
			text.back_text,
			text.back_text_position,
			text.button_font_size,
			1.0,
			rl.WHITE,
		)
	}
}


unload_gameplay_screen :: proc(g: ^entities.Game) {
	rl.UnloadFont(text.font)
	rl.UnloadFont(text.button_font)
	entities.car_unload()
	entities.obstruction_unload()
	entities.road_unload()
	entities.person_unload(g)
	entities.cow_unload()
	entities.zombie_unload(g.zombie)
}


finish_gameplay_screen :: proc(g: ^entities.Game) -> entities.GameScreen {
	return g.finish_screen
}
