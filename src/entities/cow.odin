package entities

import rl "libs:raylib"

COW_NUM :: 10
COW_TILE_WIDTH :: 16
COW_TILE_HEIGHT :: 8

cow_texture: rl.Texture2D
cow_sound: rl.Sound

Cow :: struct {
	position: rl.Vector2,
	source:   rl.Rectangle,
}


cow_init :: proc() {
	cow_texture = rl.LoadTexture("assets/sprites/animal_cow_a_16px_1.png")
	cow_sound = rl.LoadSound("assets/sounds/cow.ogg")
}


cow_randomly_place :: proc(g: ^Game) {
	for i in 0 ..< COW_NUM {
		c := Cow {
			position = rl.Vector2 {
				f32(rl.GetRandomValue(0, rl.GetScreenWidth() - i32(COW_TILE_WIDTH))),
				f32(rl.GetRandomValue(0, rl.GetScreenHeight() - i32(COW_TILE_HEIGHT))),
			},
			source   = rl.Rectangle{0, 0, COW_TILE_WIDTH, COW_TILE_HEIGHT},
		}
		g.cows[i] = c
	}
}


cow_update :: proc(g: ^Game) {
	for &cow in g.cows {
		tile_bounding_box := rl.Rectangle {
			x      = cow.position.x,
			y      = cow.position.y,
			width  = cow.source.width,
			height = cow.source.height,
		}
		if rl.CheckCollisionRecs(g.zombie.bounds, tile_bounding_box) {
			if ODIN_DEBUG {
				// TODO: make this work with web builds
				// fmt.println("Collision with cow")
			}
			rl.PlaySound(cow_sound)
			g.score += 1

			person_place(g)

			cow.position.x = f32(rl.GetRandomValue(0, rl.GetScreenWidth() - i32(cow.source.width)))
			cow.position.y = f32(
				rl.GetRandomValue(0, rl.GetScreenHeight() - i32(cow.source.height)),
			)
		}
	}
}


cow_draw :: proc(cows: [COW_NUM]Cow) {
	for cow in cows {
		rl.DrawTextureRec(cow_texture, cow.source, cow.position, rl.WHITE)
	}
}


cow_unload :: proc() {
	rl.UnloadTexture(cow_texture)
	rl.UnloadSound(cow_sound)
}
