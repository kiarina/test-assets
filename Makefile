.PHONY: build default release

.DEFAULT_GOAL := default

default: build

build:
	@mise run build

release:
	@mise run release

%:
	@mise run build $*
