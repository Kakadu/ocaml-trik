
OCAMLC=$(OCAMLROOT)/byterun/ocamlrun $(OCAMLROOT)/ocamlc

all: hello.byte

hello.byte: hello.ml
	$(OCAMLC) -vmthread $< -o $^
