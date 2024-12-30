package screens

import "core:fmt"
import rl "libs:raylib"

import "../entities"


TitleText :: struct {
	start_text:                 cstring, // = "Start"
	start_text_position:        rl.Vector2,
	start_text_size:            rl.Vector2,
	instructions_text:          cstring, //= "Instructions"
	instructions_text_position: rl.Vector2,
	instructions_text_size:     rl.Vector2,
	font:                       rl.Font,
	menu_font:                  rl.Font,
	text_size:                  rl.Vector2,
	text_position:              rl.Vector2,
	text:                       cstring, // "Zombie Like Hamburger"
	font_size:                  f32, //= 72
	button_font_size:           f32, // = 36
}

@(private = "file")
background_color: rl.Color = {0, 0, 0, 255}
@(private = "file")
text: TitleText


init_title_screen :: proc(g: ^entities.Game) {
	rl.SetMouseCursor(.DEFAULT)

	g.finish_screen = .NONE

	text = TitleText {
		start_text        = "Start",
		instructions_text = "Instructions",
		text              = "Zombie Like Hamburger",
		font_size         = 72,
		button_font_size  = 36,
	}

	text.font = rl.LoadFontEx("assets/fonts/bloody.ttf", 96, nil, 0)
	text.menu_font = rl.LoadFontEx("assets/fonts/GeosansLight.ttf", 96, nil, 0)

	rl.GenTextureMipmaps(&text.font.texture)
	rl.SetTextureFilter(text.font.texture, .POINT)

	rl.GenTextureMipmaps(&text.menu_font.texture)
	rl.SetTextureFilter(text.menu_font.texture, .POINT)

	text.text_size = rl.MeasureTextEx(text.font, text.text, text.font_size, 1.0)
	text.text_position = {
		(f32(rl.GetScreenWidth()) - text.text_size.x) / 2.0,
		(f32(rl.GetScreenHeight()) - text.text_size.y) / 2.0 - 150,
	}

	text.start_text_size = rl.MeasureTextEx(
		text.menu_font,
		text.start_text,
		text.button_font_size,
		1.0,
	)
	text.start_text_position = {
		(f32(rl.GetScreenWidth()) - text.start_text_size.x) / 2.0,
		(f32(rl.GetScreenHeight()) - text.start_text_size.y) / 2.0 + 150,
	}
	text.instructions_text_size = rl.MeasureTextEx(
		text.menu_font,
		text.instructions_text,
		text.button_font_size,
		1.0,
	)
	text.instructions_text_position = {
		(f32(rl.GetScreenWidth()) - text.instructions_text_size.x) / 2.0,
		(f32(rl.GetScreenHeight()) - text.instructions_text_size.y) / 2.0 + 200,
	}
}


update_title_screen :: proc(dt: f32, g: ^entities.Game) {
	rl.SetMouseCursor(.DEFAULT)

	mouse_position := rl.GetMousePosition()

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

	// Instructions button
	instructions_rect := rl.Rectangle {
		text.instructions_text_position.x,
		text.instructions_text_position.y,
		text.instructions_text_size.x,
		text.instructions_text_size.y,
	}
	if rl.CheckCollisionPointRec(mouse_position, instructions_rect) {
		rl.SetMouseCursor(.POINTING_HAND)
		if rl.IsMouseButtonPressed(.LEFT) {
			g.finish_screen = .INSTRUCTIONS
		}
	}
}


draw_title_screen :: proc() {
	rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), background_color)

	rl.DrawTextEx(text.font, text.text, text.text_position, text.font_size, 1.0, rl.RED)

	rl.DrawTextEx(
		text.menu_font,
		text.start_text,
		text.start_text_position,
		text.button_font_size,
		1.0,
		rl.WHITE,
	)
	rl.DrawTextEx(
		text.menu_font,
		text.instructions_text,
		text.instructions_text_position,
		text.button_font_size,
		1.0,
		rl.WHITE,
	)
}


unload_title_screen :: proc() {
	rl.UnloadFont(text.font)
	rl.UnloadFont(text.menu_font)
}


finish_title_screen :: proc(g: ^entities.Game) -> entities.GameScreen {
	return g.finish_screen
}
