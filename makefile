ui_lib_dir=../pony.ui/lib

build_dir=./build
lib_dir=./lib

all: pony run

check:
	@mkdir -p $(build_dir)
	@mkdir -p $(lib_dir)

pony: check copy-libs
	corral run -- ponyc --extfun -p $(lib_dir) -o ./build/ ./laba

copy-libs:
	@cp ${ui_lib_dir}/*.a ./lib/

clean:
	rm -rf $(build_dir)

run:
	./build/laba

test: check-folders copy-libs
	corral run -- ponyc --extfun -V=0 -p $(lib_dir) -o ./build/ ./laba
	./build/laba





corral-fetch:
	@corral clean -q
	@corral fetch -q

corral-local:
	-@rm corral.json
	-@rm lock.json
	@corral init -q
	@corral add /Volumes/Development/Development/pony/pony.ui -q
	@corral add /Volumes/Development/Development/pony/pony.easings -q
	@corral add /Volumes/Development/Development/pony/pony.utility -q
	@corral add /Volumes/Development/Development/pony/pony.stringext -q
	@corral add /Volumes/Development/Development/pony/ponylang-linal -q

corral-git:
	-@rm corral.json
	-@rm lock.json
	@corral init -q
	@corral add github.com/KittyMac/pony.ui.git -q
	@corral add github.com/KittyMac/pony.easings.git -q
	@corral add github.com/KittyMac/pony.utility.git -q
	@corral add github.com/KittyMac/pony.stringext.git -q
	@corral add github.com/KittyMac/ponylang-linal.git -q

ci: ui_lib_dir = ./_corral/github_com_KittyMac_pony_ui/lib/
ci: corral-git corral-fetch all
	
dev: corral-local corral-fetch all

