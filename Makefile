NM=nm
OCAMLWHERE=`ocamlc -where`
OCAMLC=ocamlfind     c -g -cc g++ -verbose -package threads -vmthread
OCAMLOPT=ocamlfind opt -g -cc g++ -verbose -package threads -thread

OCAML_HEADERS_DIR=$(OCAMLWHERE)/caml
THREADS_DIR=$(OCAMLWHERE)/vmthreads
CXXFLAGS=-std=c++11
OCAMLC_TARGET_OPTS=-custom -cc "g++" \
	-ccopt -L$(THREADS_DIR)  $(THREADS_DIR)/threads.cma \
	-cclib -lstdc++ -verbose

QTMODULES ?= QtGui
OCAMLC_CLINK_OPTS += $(addprefix -cclib ,$(shell pkg-config --libs $(QTMODULES) ) )
OCAMLC_CLINK_OPTS += -cclib -lstdc++

OCAML_CXXFLAGS =  $(addprefix -ccopt , $(CXXFLAGS) )
OCAML_CXXFLAGS += $(addprefix -ccopt , $(shell pkg-config --cflags $(QTMODULES) ) )
OCAML_CXXFLAGS += -ccopt -I$(OCAML_HEADERS_DIR) -ccopt -I$(OCAMLWHERE)/threads/ #-ccopt -save-temps
OCAML_CXXFLAGS += -ccopt -fPIC


all: hello.byte

wrap.o: wrap.c
	$(OCAMLC) -cc "$(CXX)" $(OCAML_CXXFLAGS) -c $< -o $@
	file  $@
	$(NM) $@

funs.cmo: funs.ml
	$(OCAMLC) -c $< -o $@

funs.cmx: funs.ml
	$(OCAMLOPT) -c $< -o $@

hello.cmo: hello.ml
	$(OCAMLC) -c -vmthread $< -o $@

hello.cmx: hello.ml
	$(OCAMLOPT) -c -thread $< -o $@

hello.byte: wrap.o funs.cmo hello.cmo
	echo linking byte code
	$(OCAMLC) -custom -linkpkg $^ $(OCAMLC_CLINK_OPTS)  -o $@

hello.native: wrap.o funs.cmx hello.cmx
	echo linking native code
	$(OCAMLOPT) -linkpkg -cc g++ $^ $(OCAMLC_CLINK_OPTS) -o $@


hello.tar.xz: hello.byte
	tar --xz -cf threads.tar.xz hello.byte
	#cp hello.byte ~/h

clean:
	rm -fr *.o *.cm[ioax] hello.byte hello.native *.ii *.s

hello.cmo: funs.cmo

.PHONY: all clean
