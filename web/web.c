#include <emscripten/emscripten.h>
#include <stdio.h>

extern void game_init();
extern void game_update();
extern void game_dispose();

int main() {
  game_init();
  emscripten_set_main_loop(game_update, 0, 1);
  game_dispose();
  return 0;
}
