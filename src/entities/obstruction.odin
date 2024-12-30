package entities

import rl "libs:raylib"

OBSTRUCTION_NUM :: 5

obstruction_texture: rl.Texture2D

Obstruction :: struct {
	position:          rl.Vector2,
	source:            rl.Rectangle,
	bounding_x_offset: f32,
	bounding_y_offset: f32,
}


obstruction_init :: proc() {
	obstruction_texture = rl.LoadTexture("assets/sprites/scenery_4.png")
}


obstruction_update :: proc(g: ^Game, old_zombie_x: f32, old_zombie_y: f32) {
	for obstruction in g.obstructions {
		obstruction_bb := rl.Rectangle {
			obstruction.position.x - obstruction.bounding_x_offset,
			obstruction.position.y - obstruction.bounding_y_offset,
			obstruction.source.width + obstruction.bounding_x_offset * 2,
			obstruction.source.height + obstruction.bounding_y_offset * 2,
		}

		if rl.CheckCollisionRecs(g.zombie.bounds, obstruction_bb) {
			g.zombie.position.x = old_zombie_x
			g.zombie.position.y = old_zombie_y
			break
		}
	}
}


obstruction_draw :: proc(obstructions: [OBSTRUCTION_NUM]Obstruction) {
	for o in obstructions {
		rl.DrawTextureRec(obstruction_texture, o.source, o.position, rl.WHITE)
		if ODIN_DEBUG {
			rl.DrawRectangleLines(
				i32(o.position.x) - i32(o.bounding_x_offset),
				i32(o.position.y) - i32(o.bounding_y_offset),
				i32(o.source.width) + i32(o.bounding_x_offset) * 2,
				i32(o.source.height) + i32(o.bounding_y_offset) * 2,
				rl.GREEN,
			)
		}
	}
}


obstruction_unload :: proc() {
	rl.UnloadTexture(obstruction_texture)
}


obstructions_place :: proc(g: ^Game) {
	for i in 0 ..< OBSTRUCTION_NUM {
		obstruction_place(g, i)
	}
}


obstruction_place :: proc(g: ^Game, i: int) {
	width: f32 = 64.0
	height: f32 = 64.0

	for {
		x := f32(rl.GetRandomValue(0, rl.GetScreenWidth() - i32(width)))
		y := f32(rl.GetRandomValue(0, rl.GetScreenHeight() - i32(height)))

		new_rect := rl.Rectangle{x, y, width, height}

		if obstruction_can_place(new_rect, g) {
			o := Obstruction {
				position          = rl.Vector2{x, y},
				source            = rl.Rectangle{0, 0, width, height},
				bounding_x_offset = -5,
				bounding_y_offset = -5,
			}
			g.obstructions[i] = o
			break
		}
	}
}


obstruction_can_place :: proc(new_rect: rl.Rectangle, g: ^Game) -> bool {
	// Check road tiles
	for road_tile in g.roads {
		road_bb := rl.Rectangle {
			road_tile.position.x,
			road_tile.position.y,
			ROAD_TILE_SIZE,
			ROAD_TILE_SIZE,
		}
		if rl.CheckCollisionRecs(new_rect, road_bb) {
			return false
		}
	}

	// Check cows
	for &cow in g.cows {
		cow_bb := rl.Rectangle{cow.position.x, cow.position.y, cow.source.width, cow.source.height}
		if rl.CheckCollisionRecs(new_rect, cow_bb) {
			return false
		}
	}

	// Check people
	for &p in g.people {
		person_bb := rl.Rectangle{p.position.x, p.position.y, p.width, p.height}
		if rl.CheckCollisionRecs(new_rect, person_bb) {
			return false
		}
	}

	// Check zombie’s starting position
	zombie_bb := rl.Rectangle {
		g.zombie.position.x,
		g.zombie.position.y,
		g.zombie.width,
		g.zombie.height,
	}
	if rl.CheckCollisionRecs(new_rect, zombie_bb) {
		return false
	}

	return true
}
