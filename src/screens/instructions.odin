package screens

import "core:fmt"
import rl "libs:raylib"

import "../config"
import "../entities"


InstructionsText :: struct {
	start_text:          cstring, // = "Start"
	start_text_position: rl.Vector2,
	start_text_size:     rl.Vector2,
	back_text:           cstring, // = "Back"
	back_text_position:  rl.Vector2,
	back_text_size:      rl.Vector2,
	button_font_size:    f32, // = 36
	font:                rl.Font,
	instructions_font:   rl.Font,
	title_text_size:     rl.Vector2,
	title_text_position: rl.Vector2,
	title_text:          cstring, // = "Instructions"
	title_font_size:     f32, // = 72
	font_size:           f32, //= 24
	start_position_y:    f32, // = 175
	start_position_x:    f32, // = 50
}

@(private = "file")
cow: rl.Texture2D
@(private = "file")
car: rl.Texture2D
@(private = "file")
zombie: rl.Texture2D
@(private = "file")
people: rl.Texture2D
@(private = "file")
background_color: rl.Color = {0, 0, 0, 255}
@(private = "file")
text: InstructionsText


init_instructions_screen :: proc(g: ^entities.Game) {
	rl.SetMouseCursor(.DEFAULT)

	g.finish_screen = .NONE

	text = InstructionsText {
		start_text        = "Start",
		back_text         = "Back",
		button_font_size  = 36,
		title_text        = "Instructions",
		title_font_size   = 72,
		font_size         = 24,
		start_position_y  = 175,
		start_position_x  = 50,
		font              = rl.LoadFontEx("assets/fonts/bloody.ttf", 96, nil, 0),
		instructions_font = rl.LoadFontEx("assets/fonts/GeosansLight.ttf", 96, nil, 0),
	}

	cow = rl.LoadTexture("assets/sprites/animal_cow_a_16px_1.png")
	zombie = rl.LoadTexture("assets/sprites/zombie_8px_right_1.png")
	people = rl.LoadTexture("assets/sprites/people_a_right_1.png")
	car = rl.LoadTexture("assets/sprites/car_24px_8way_blue_1.png")

	rl.GenTextureMipmaps(&text.font.texture)
	rl.SetTextureFilter(text.font.texture, .POINT)

	rl.GenTextureMipmaps(&text.instructions_font.texture)
	rl.SetTextureFilter(text.instructions_font.texture, .POINT)

	text.title_text_size = rl.MeasureTextEx(text.font, text.title_text, text.title_font_size, 1.0)
	text.title_text_position = {
		(f32(rl.GetScreenWidth()) - text.title_text_size.x) / 2.0,
		(f32(rl.GetScreenHeight()) - text.title_text_size.y) / 2.0 - 200,
	}

	text.start_text_size = rl.MeasureTextEx(text.instructions_font, text.start_text, 36.0, 1.0)
	text.start_text_position = {
		(f32(rl.GetScreenWidth()) - text.start_text_size.x) / 2.0,
		(f32(rl.GetScreenHeight()) - text.start_text_size.y) / 2.0 + 175,
	}
	text.back_text_size = rl.MeasureTextEx(text.instructions_font, text.back_text, 36.0, 1.0)
	text.back_text_position = {
		(f32(rl.GetScreenWidth()) - text.back_text_size.x) / 2.0,
		(f32(rl.GetScreenHeight()) - text.back_text_size.y) / 2.0 + 225,
	}
}


update_instructions_screen :: proc(dt: f32, g: ^entities.Game) {
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


draw_instructions_screen :: proc(g: ^entities.Game) {
	rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), background_color)

	rl.DrawTextEx(
		text.font,
		text.title_text,
		text.title_text_position,
		text.title_font_size,
		1.0,
		rl.RED,
	)

	rl.DrawTextEx(
		text.instructions_font,
		"You zombie.\nZombie like hamburger.\nZombie no like brains.\nCars no taste good either.",
		{text.start_position_x, text.start_position_y},
		text.font_size,
		1,
		rl.WHITE,
	)

	rl.DrawTextureEx(
		zombie,
		rl.Vector2{text.start_position_x + 115, text.start_position_y},
		0,
		2,
		rl.WHITE,
	)
	rl.DrawTexture(
		cow,
		i32(text.start_position_x) + 225,
		i32(text.start_position_y) + 35,
		rl.WHITE,
	)
	rl.DrawTextureEx(
		people,
		rl.Vector2{text.start_position_x + 215, text.start_position_y + 55},
		0,
		2,
		rl.WHITE,
	)
	rl.DrawTexture(
		car,
		i32(text.start_position_x) + 250,
		i32(text.start_position_y) + 75,
		rl.WHITE,
	)

	rl.DrawTextEx(
		text.instructions_font,
		"Arrow or WASD move.\nEat hamburger that makes moo.\nNo eat humans.\nNo eat cars.",
		{text.start_position_x, text.start_position_y + 125},
		text.font_size,
		1,
		rl.WHITE,
	)

	rl.DrawTextEx(
		text.instructions_font,
		text.start_text,
		text.start_text_position,
		text.button_font_size,
		1.0,
		rl.WHITE,
	)
	rl.DrawTextEx(
		text.instructions_font,
		text.back_text,
		text.back_text_position,
		text.button_font_size,
		1.0,
		rl.WHITE,
	)
}


unload_instructions_screen :: proc() {
	rl.UnloadFont(text.font)
	rl.UnloadFont(text.instructions_font)
	rl.UnloadTexture(cow)
	rl.UnloadTexture(zombie)
	rl.UnloadTexture(people)
	rl.UnloadTexture(car)
}


finish_instructions_screen :: proc(g: ^entities.Game) -> entities.GameScreen {
	return g.finish_screen
}
