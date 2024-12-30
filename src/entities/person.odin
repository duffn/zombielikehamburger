package entities

import "core:fmt"
import rl "libs:raylib"


PEOPLE_NUM :: 20
PEOPLE_FRAME_COUNT_X :: 4
PEOPLE_FRAME_COUNT_Y :: 16
PERSON_SCALE :: 2

person_texture: rl.Texture2D

Person :: struct {
	position:      rl.Vector2,
	direction:     int, // 0=right, 1=down, 2=left, 3=up
	char_block:    int, // which "character block" (0..3)
	speed:         f32,
	current_row:   int,
	current_frame: int,
	anim_timer:    f32,
	animation_fps: f32,
	frame_width:   f32,
	frame_height:  f32,
	scale:         int,
	width:         f32,
	height:        f32,
	is_moving:     bool,
	bounds:        rl.Rectangle,
}


person_init :: proc(g: ^Game) {
	person_texture = rl.LoadTexture("assets/sprites/people_8px_4_types.png")
}


person_make :: proc() -> Person {
	p := Person {
		position      = rl.Vector2{0, 0},
		speed         = 100,
		current_row   = 0,
		current_frame = 0,
		scale         = 2,
		is_moving     = false,
		animation_fps = 12,
		anim_timer    = 0,
	}

	p.frame_width = f32(person_texture.width) / f32(PEOPLE_FRAME_COUNT_X)
	p.frame_height = f32(person_texture.height) / f32(PEOPLE_FRAME_COUNT_Y)
	p.width = p.frame_width * f32(p.scale)
	p.height = p.frame_height * f32(p.scale)
	p.bounds = rl.Rectangle{p.position.x, p.position.y, p.width, p.height}

	return p
}


person_update :: proc(g: ^Game, dt: f32) {
	for i in 0 ..< len(g.people) {
		person := &g.people[i]

		// Move in current direction
		switch person.direction {
		case 0:
			// right
			person.position.x += person.speed * dt
		case 1:
			// down
			person.position.y += person.speed * dt
		case 2:
			// left
			person.position.x -= person.speed * dt
		case 3:
			// up
			person.position.y -= person.speed * dt
		}

		// Bounce off edges to avoid sticking
		// Left edge
		if person.position.x < 0 {
			person.position.x = 0
			if person.direction == 2 {
				person.direction = 0
			}
		}
		// Right edge
		max_x := f32(rl.GetScreenWidth()) - person.width
		if person.position.x > max_x {
			person.position.x = max_x
			if person.direction == 0 {
				person.direction = 2
			}
		}
		// Top edge
		if person.position.y < 0 {
			person.position.y = 0
			if person.direction == 3 {
				person.direction = 1
			}
		}
		// Bottom edge
		max_y := f32(rl.GetScreenHeight()) - person.height
		if person.position.y > max_y {
			person.position.y = max_y
			if person.direction == 1 {
				person.direction = 3
			}
		}

		// Update the row based on new direction
		person.current_row = person.char_block * 4 + person.direction

		// Animate frames horizontally
		person.anim_timer += dt
		if person.anim_timer >= 1 / person.animation_fps {
			person.anim_timer = 0
			person.current_frame += 1
			if person.current_frame >= PEOPLE_FRAME_COUNT_X {
				person.current_frame = 0
			}
		}

		person_bounds := rl.Rectangle {
			person.position.x,
			person.position.y,
			person.width,
			person.height,
		}

		if rl.CheckCollisionRecs(g.zombie.bounds, person_bounds) {
			if ODIN_DEBUG {
				// fmt.println("Collision with person")
			}
			rl.PlaySound(g.zombie.death_sound)

			g.is_game_over = true
		}
	}
}


person_draw :: proc(people: [dynamic]Person) {
	for p in people {
		source_rect := rl.Rectangle {
			f32(p.current_frame) * p.frame_width,
			f32(p.current_row) * p.frame_height,
			p.frame_width,
			p.frame_height,
		}
		dest_rect := rl.Rectangle{p.position.x, p.position.y, p.width, p.height}
		rl.DrawTexturePro(person_texture, source_rect, dest_rect, rl.Vector2{0, 0}, 0, rl.WHITE)
		if ODIN_DEBUG {
			rl.DrawRectangleLines(
				i32(p.position.x),
				i32(p.position.y),
				i32(p.width),
				i32(p.height),
				rl.ORANGE,
			)
		}
	}
}

person_unload :: proc(g: ^Game) {
	rl.UnloadTexture(person_texture)
}


people_place :: proc(g: ^Game) {
	for i in 0 ..< PEOPLE_NUM {
		person_place(g)
	}
}


person_place :: proc(g: ^Game) {
	min_distance: f32 = 100
	x := f32(0)
	y := f32(0)

	p := person_make()

	for {
		x = f32(rl.GetRandomValue(0, rl.GetScreenWidth() - i32(p.width)))
		y = f32(rl.GetRandomValue(0, rl.GetScreenHeight() - i32(p.height)))

		dx := x - g.zombie.position.x
		dy := y - g.zombie.position.y

		dist_sqr := dx * dx + dy * dy
		if dist_sqr >= min_distance * min_distance {
			break
		}
	}

	// Random direction: 0=right, 1=down, 2=left, 3=up
	dir := rl.GetRandomValue(0, 3)
	char_block := rl.GetRandomValue(0, 3)

	spd := f32(rl.GetRandomValue(50, 100))

	p.position = rl.Vector2{x, y}
	p.direction = int(dir)
	p.speed = spd
	p.char_block = int(char_block)
	p.current_row = int(dir)

	append(&g.people, p)
}
