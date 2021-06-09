src/source_loi.ml: src/source_loi.catala_fr
	catala --optimize --language=fr OCaml src/source_loi.catala_fr

format:
	dune build @fmt --auto-promote 2> /dev/null | true

build: src/source_loi.ml format
	dune build src/soutenance.exe

test: build
	dune exec src/soutenance.exe -- tests/denis.md

denis:
	node dist/soutenance.js tests/denis.md

INSTALL_DIR=dist

explain:
	catala --wrap --language=fr LaTeX src/source_loi.catala_fr
	latexmk -pdf -halt-on-error -shell-escape src/source_loi.tex

install:
	dune build --profile=release src/soutenance.bc.js
	mkdir -p $(INSTALL_DIR)
	cp _build/default/src/soutenance.bc.js $(INSTALL_DIR)/soutenance.js