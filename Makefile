PACKAGE := zombielikehamburger

STACK_SIZE := 1048576
HEAP_SIZE := 67108864

build-desktop:
	rm -rf out/debug/desktop
	mkdir -p out/debug/desktop
	cp -R ./assets out/debug/desktop
	odin build desktop --collection:libs=libs -out:"out/debug/desktop/${PACKAGE}" -debug

build-desktop-release:
	rm -rf out/release/desktop
	mkdir -p out/release/desktop
	cp -R ./assets out/release/desktop
	odin build desktop --collection:libs=libs -out:"out/release/desktop/${PACKAGE}" 
build-web:
	rm -rf out/debug/web
	rm -rf out/debug/.intermediate
	mkdir -p out/debug/web
	mkdir -p out/debug/.intermediate
	cp -R ./assets out/debug/web
	odin build web --collection:libs=libs -target=freestanding_wasm32 -out:"out/debug/.intermediate/$(PACKAGE)" -build-mode:obj -debug -show-system-calls
	emcc -o out/debug/web/index.html web/web.c out/debug/.intermediate/$(PACKAGE).wasm.o libs/raylib/web/libraylib.a -sUSE_GLFW=3 -sGL_ENABLE_GET_PROC_ADDRESS -DWEB_BUILD -DRAYLIB_ASYNC_ENABLE -sASYNCIFY -O3 -sSTACK_SIZE=$(STACK_SIZE) -sTOTAL_MEMORY=$(HEAP_SIZE) -sERROR_ON_UNDEFINED_SYMBOLS=0 -sFORCE_FILESYSTEM=1 -sWASM=1 --preload-file assets/ --shell-file web/minshell.html

build-web-release:
	rm -rf out/release/web
	rm -rf out/release/.intermediate
	mkdir -p out/release/web
	mkdir -p out/release/.intermediate
	cp -R ./assets out/release/web
	odin build web --collection:libs=libs -target=freestanding_wasm32 -out:"out/release/.intermediate/$(PACKAGE)" -build-mode:obj -o:size
	emcc -o out/release/web/index.html web/web.c out/release/.intermediate/$(PACKAGE).wasm.o libs/raylib/web/libraylib.a -sUSE_GLFW=3 -sGL_ENABLE_GET_PROC_ADDRESS -DWEB_BUILD -DRAYLIB_ASYNC_ENABLE -sASYNCIFY -O3 -sSTACK_SIZE=$(STACK_SIZE) -sTOTAL_MEMORY=$(HEAP_SIZE) -sERROR_ON_UNDEFINED_SYMBOLS=0 -sFORCE_FILESYSTEM=1 -sWASM=1 --preload-file assets/ --shell-file web/minshell.html
