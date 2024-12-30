package entities

import rl "libs:raylib"

ROAD_TILE_SIZE :: 64

road_texture: rl.Texture2D

Road :: struct {
	position: rl.Vector2,
	source:   rl.Rectangle,
}


road_init :: proc() {
	road_texture = rl.LoadTexture("assets/sprites/road_64px_a_3.png")
}


road_draw :: proc(roads: [dynamic]Road) {
	for road in roads {
		rl.DrawRectangle(
			i32(road.position.x), // Draw the road
			i32(road.position.y),
			ROAD_TILE_SIZE,
			ROAD_TILE_SIZE,
			rl.WHITE,
		)
		rl.DrawTextureRec(road_texture, road.source, road.position, rl.WHITE)
	}
}


road_unload :: proc() {
	rl.UnloadTexture(road_texture)
}


roads_place :: proc(g: ^Game, used_x_positions: ^[dynamic]f32) {
	num_roads := rl.GetRandomValue(4, 6)
	for i in 0 ..< num_roads {
		road_place(g, used_x_positions)
	}
}


road_place :: proc(g: ^Game, used_x_positions: ^[dynamic]f32) {
	random_x := f32(rl.GetRandomValue(0, rl.GetScreenWidth() - ROAD_TILE_SIZE))

	for {
		random_x = f32(rl.GetRandomValue(0, rl.GetScreenWidth() - i32(ROAD_TILE_SIZE)))
		overlap := false

		for &x in used_x_positions {
			if abs(random_x - x) < ROAD_TILE_SIZE {
				overlap = true
				break
			}
		}

		if !overlap {
			break
		}
	}

	append(used_x_positions, random_x)

	for i in 0 ..< rl.GetScreenHeight() / ROAD_TILE_SIZE {
		r: Road = {
			position = rl.Vector2{random_x, f32(i * ROAD_TILE_SIZE)},
			source   = rl.Rectangle{0, 0, ROAD_TILE_SIZE, ROAD_TILE_SIZE},
		}
		append(&g.roads, r)
	}
}


road_group_tiles_by_x :: proc(roads: [dynamic]Road) -> map[int]Road {
	result := make(map[int]Road)

	for tile in roads {
		result[int(tile.position.x)] = tile
	}

	return result
}
