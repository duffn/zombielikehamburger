package entities

import rl "libs:raylib"

Transition :: struct {
	trans_alpha:       f32,
	on_transition:     bool,
	trans_fade_out:    bool,
	trans_from_screen: GameScreen,
	trans_to_screen:   GameScreen,
}

Game :: struct {
	transition:     Transition,
	current_screen: GameScreen,
	music:          rl.Music,
	score:          int,
	is_game_over:   bool,
	zombie:         Zombie,
	cows:           [COW_NUM]Cow,
	people:         [dynamic]Person,
	roads:          [dynamic]Road,
	obstructions:   [OBSTRUCTION_NUM]Obstruction,
	cars:           [dynamic]Car,
	finish_screen:  GameScreen,
}
