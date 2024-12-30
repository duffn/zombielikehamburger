package entities

import "core:fmt"
import "core:math"
import rl "libs:raylib"

import "../config"

Zombie :: struct {
	texture:         rl.Texture2D,
	frame_count_x:   int,
	frame_count_y:   int,
	frame_width:     f32,
	frame_height:    f32,
	scale:           int,
	width:           f32,
	height:          f32,
	position:        rl.Vector2,
	speed:           f32,
	is_moving:       bool,
	bounds:          rl.Rectangle,
	current_row:     int,
	current_frame:   int,
	pulse_timer:     f32,
	pulse_phase:     f32,
	pulse_base_rad:  f32,
	pulse_amp:       f32,
	pulse_freq:      f32,
	animation_fps:   f32,
	animation_timer: f32,
	death_sound:     rl.Sound,
}


zombie_init :: proc(g: ^Game) {
	z := Zombie {
		frame_count_x   = 4,
		frame_count_y   = 4,
		scale           = 2,
		speed           = 100,
		pulse_timer     = 3.0,
		pulse_base_rad  = 40.0,
		pulse_amp       = 10.0,
		pulse_freq      = 2.0,
		pulse_phase     = 0.0,
		animation_timer = 0,
		animation_fps   = 12,
		current_frame   = 0,
	}
	z.texture = rl.LoadTexture("assets/sprites/zombies_8px.png")
	z.death_sound = rl.LoadSound("assets/sounds/death.mp3")
	z.position = rl.Vector2{0, 0}
	z.frame_width = f32(z.texture.width) / f32(z.frame_count_x)
	z.frame_height = f32(z.texture.height) / f32(z.frame_count_y)
	z.width = z.frame_width * f32(z.scale)
	z.height = z.frame_height * f32(z.scale)
	z.bounds = rl.Rectangle{z.position.x, z.position.y, z.width, z.height}

	g.zombie = z
}


zombie_randomly_place :: proc(z: ^Zombie, used_x_positions: [dynamic]f32) {
	for {
		candidate_x := f32(rl.GetRandomValue(0, rl.GetScreenWidth() - i32(z.width)))

		overlap := false
		for x in used_x_positions {
			if abs(candidate_x - x) < ROAD_TILE_SIZE {
				overlap = true
				break
			}
		}

		if !overlap {
			z.position.x = candidate_x
			break
		}
	}

	z.position.y = f32(rl.GetRandomValue(0, i32(rl.GetScreenHeight()) - i32(z.height)))
}

zombie_update :: proc(z: ^Zombie, dt: f32) {
	if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D) {
		z.current_row = 0
		z.position.x += z.speed * dt
		z.is_moving = true
	}
	if rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.S) {
		z.current_row = 1
		z.position.y += z.speed * dt
		z.is_moving = true
	}
	if rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A) {
		z.current_row = 2
		z.position.x -= z.speed * dt
		z.is_moving = true
	}
	if rl.IsKeyDown(.UP) || rl.IsKeyDown(.W) {
		z.current_row = 3
		z.position.y -= z.speed * dt
		z.is_moving = true
	}
	if z.position.x < 0 {
		z.position.x = 0
	}
	if z.position.y < 0 {
		z.position.y = 0
	}
	if z.position.x > f32(rl.GetScreenWidth()) - z.width {
		z.position.x = f32(rl.GetScreenWidth()) - z.width
	}
	if z.position.y > f32(rl.GetScreenHeight()) - z.height {
		z.position.y = f32(rl.GetScreenHeight()) - z.height
	}

	if z.is_moving {
		z.animation_timer += dt
		if z.animation_timer >= 1 / z.animation_fps {
			z.animation_timer = 0
			z.current_frame += 1
			if z.current_frame >= z.frame_count_x {
				z.current_frame = 0
			}
		}
	} else {
		z.current_frame = 0
		z.animation_timer = 0
	}

	z.bounds = rl.Rectangle{z.position.x, z.position.y, z.width, z.height}
}


zombie_update_pulse_timer :: proc(z: ^Zombie, dt: f32) {
	if z.pulse_timer > 0 {
		z.pulse_timer -= dt
		if z.pulse_timer < 0 {
			z.pulse_timer = 0
		}
		z.pulse_phase += dt
	}
}


zombie_draw :: proc(z: Zombie) {
	rl.DrawTexturePro(
		z.texture,
		{
			f32(z.current_frame) * z.frame_width,
			f32(z.current_row) * z.frame_height,
			z.frame_width,
			z.frame_height,
		},
		{z.position.x, z.position.y, z.width, z.height},
		{0, 0},
		0,
		rl.WHITE,
	)

	if z.pulse_timer > 0 {
		t := z.pulse_timer / 3.0
		alpha := u8(175.0 * t)
		color := rl.Color{255, 255, 255, alpha}

		radius_offset := z.pulse_amp * math.sin(2.0 * rl.PI * z.pulse_freq * z.pulse_phase)
		pulse_radius := z.pulse_base_rad + radius_offset

		center := rl.Vector2{z.position.x + (z.width / 2), z.position.y + (z.height / 2)}

		rl.DrawCircleV(center, pulse_radius, color)
	}
}


zombie_unload :: proc(z: Zombie) {
	rl.UnloadTexture(z.texture)
	rl.UnloadSound(z.death_sound)
}
