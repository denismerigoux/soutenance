src/source_loi.ml: src/source_loi.catala_fr
	catala --optimize --language=fr OCaml src/source_loi.catala_fr

format:
	dune build @fmt --auto-promote 2> /dev/null | true

build: src/source_loi.ml format
	dune build src/soutenance.exe

test: build
	dune exec src/soutenance.exe -- tests/jury.md -p 0.3