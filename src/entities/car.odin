package entities

import rl "libs:raylib"

CAR_NUM_FRAMES :: 8
CAR_TILE_SIZE :: 24

blue_car_texture: rl.Texture2D
pink_car_texture: rl.Texture2D

CarType :: enum {
	Blue,
	Pink,
}

Car :: struct {
	speed:    f32,
	position: rl.Vector2,
	texture:  rl.Texture2D,
	frame:    rl.Rectangle,
	type:     CarType,
}


car_init :: proc() {
	blue_car_texture = rl.LoadTexture("assets/sprites/car_24px_8way_blue.png")
	pink_car_texture = rl.LoadTexture("assets/sprites/car_24px_8way_pink.png")
}


car_update :: proc(g: ^Game, dt: f32) {
	for &car in g.cars {
		switch car.type {
		case .Blue:
			car.position.y += car.speed * dt
			if car.position.y > f32(rl.GetScreenHeight()) + 100 {
				car.position.y = -100
			}
		case .Pink:
			car.position.y -= car.speed * dt
			if car.position.y < -100 {
				car.position.y = f32(rl.GetScreenHeight()) + 100
			}
		}

		car_bounding_box := rl.Rectangle {
			x      = car.position.x,
			y      = car.position.y,
			width  = car.frame.width,
			height = car.frame.height,
		}
		if rl.CheckCollisionRecs(g.zombie.bounds, car_bounding_box) {
			if ODIN_DEBUG {
				// fmt.eprintln("Collision with blue car")
			}
			rl.PlaySound(g.zombie.death_sound)

			g.is_game_over = true
		}
	}
}


car_draw :: proc(cars: [dynamic]Car) {
	for car in cars {
		rl.DrawTextureRec(car.texture, car.frame, {car.position.x, car.position.y}, rl.WHITE)
		if ODIN_DEBUG {
			rl.DrawRectangleLines(
				i32(car.position.x),
				i32(car.position.y),
				i32(car.frame.width),
				i32(car.frame.height),
				rl.RED,
			)
		}
	}
}


car_unload :: proc() {
	rl.UnloadTexture(blue_car_texture)
	rl.UnloadTexture(pink_car_texture)
}


cars_place :: proc(g: ^Game) {
	result := road_group_tiles_by_x(g.roads)
	defer delete(result)
	for tile in result {
		bc := car_make(.Blue)
		bc.position.x = f32(tile) + 5
		bc.position.y = -100
		bc.speed = f32(rl.GetRandomValue(200, 1000))
		append(&g.cars, bc)

		pc := car_make(.Pink)
		pc.position.x = f32(tile) + 35
		pc.position.y = f32(rl.GetScreenHeight()) - f32(pc.texture.height) + 100
		pc.speed = f32(rl.GetRandomValue(200, 1000))
		append(&g.cars, pc)
	}
}


car_make :: proc(car_type: CarType) -> Car {
	texture: rl.Texture2D
	switch car_type {
	case .Blue:
		texture = blue_car_texture
	case .Pink:
		texture = pink_car_texture
	}

	c := Car {
		texture = texture,
		type    = car_type,
	}

	frame := rl.Rectangle{0, 0, f32(texture.width) / CAR_NUM_FRAMES, f32(texture.height)}
	c.frame = frame
	c.frame.x = frame.width * 2
	c.position = rl.Vector2{0, 0}

	return c
}
