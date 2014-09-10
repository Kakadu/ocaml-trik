ifdef OCAMLROOT
OCAMLWHERE=$(OCAMLROOT)/byterun
CC=/usr/bin/arm-linux-gnueabi-gcc
NM=/usr/bin/arm-linux-gnueabi-nm
OCAMLC2=$(OCAMLROOT)/byterun/ocamlrun $(OCAMLROOT)/ocamlc -I $(OCAMLROOT)/stdlib
OCAMLC=ocamlc

else
OCAMLWHERE=`ocamlc -where`/caml
CC=cc
NM=nm
OCAMLC=ocamlc
OCAMLC2=$(OCAMLC)
endif

all: hello.byte

wrap.o: wrap.c
	$(OCAMLC) -cc $(CC) -ccopt -I$(OCAMLWHERE) -c $< -o $@
	$(NM) $@

funs.cmo: funs.ml
	$(OCAMLC) -c $< -o $@

hello.cmo: hello.ml
	$(OCAMLC) -c $< -o $@

hello.byte: wrap.o funs.cmo hello.cmo
	$(OCAMLC2) -custom $^ -o $@ -verbose

clean:
	rm -fr *.o *.cm[ioax] hello.byte

hello.cmo: funs.cmo

.PHONY: all clean