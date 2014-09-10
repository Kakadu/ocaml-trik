ifdef OCAMLROOT
OCAMLWHERE=$(OCAMLROOT)/byterun
CC=/usr/bin/arm-linux-gnueabi-gcc
NM=/usr/bin/arm-linux-gnueabi-nm
OCAMLC2=$(OCAMLROOT)/byterun/ocamlrun $(OCAMLROOT)/ocamlc -I $(OCAMLROOT)/stdlib
OCAMLC=ocamlc
OCAML_HEADERS_DIR=$(OCAMLROOT)/byterun
THREADS_DIR=$(OCAMLROOT)/otherlibs/threads

else
OCAMLWHERE=`ocamlc -where`
CC=cc
NM=nm
OCAMLC=ocamlc
OCAMLC2=$(OCAMLC)
OCAML_HEADERS_DIR=$(OCAMLWHERE)/caml
THREADS_DIR=$(OCAMLWHERE)/vmthreads
endif

all: hello.tar.xz

wrap.o: wrap.c
	$(OCAMLC) -cc $(CC) -ccopt -I$(OCAML_HEADERS_DIR) -c $< -o $@
	$(NM) $@

funs.cmo: funs.ml
	$(OCAMLC) -c $< -o $@

hello.cmo: hello.ml
	$(OCAMLC) -c -vmthread $< -o $@

hello.byte: wrap.o funs.cmo hello.cmo
	$(OCAMLC2) -custom -ccopt -static -ccopt -L$(THREADS_DIR)  -cclib -lvmthreads $(THREADS_DIR)/threads.cma $^ -o $@ -verbose

hello.tar.xz: hello.byte
	tar --xz -cf threads.tar.xz hello.byte

clean:
	rm -fr *.o *.cm[ioax] hello.byte

hello.cmo: funs.cmo

.PHONY: all clean