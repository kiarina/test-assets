.PHONY: setup create add build release download

.DEFAULT_GOAL := build

setup:
	@mise run setup

create:
	@mise run create

add:
	@mise run add

build:
	@mise run build

release:
	@mise run release

download:
	@mise run test-assets:download
