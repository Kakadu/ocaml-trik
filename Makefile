NM=nm
OCAMLWHERE=`ocamlc -where`
OCAMLC=ocamlfind c -verbose
OCAML_HEADERS_DIR=$(OCAMLWHERE)/caml
THREADS_DIR=$(OCAMLWHERE)/vmthreads
CXXFLAGS=-std=c++11 -ItrikRuntime/trikControl/include
OCAMLC_TARGET_OPTS=-custom -cc "g++" \
	-ccopt -L$(THREADS_DIR)  $(THREADS_DIR)/threads.cma \
	-cclib -lstdc++ -verbose
QTMODULES=Qt5Widgets
OCAMLC_TARGET_OPTS += $(addprefix -cclib ,$(shell pkg-config --libs $(QTMODULES) ) )
OCAMLC_TARGET_OPTS += -ccopt -Llibs #-ccopt --verbose

OCAML_CXXFLAGS =  $(addprefix -ccopt , $(CXXFLAGS) )
OCAML_CXXFLAGS += $(addprefix -ccopt , $(shell pkg-config --cflags $(QTMODULES) ) )
OCAML_CXXFLAGS += -ccopt -I$(OCAML_HEADERS_DIR) -ccopt -I$(OCAMLWHERE)/threads/ -ccopt -save-temps
OCAML_CXXFLAGS += -ccopt -fPIC

all: hello.tar.xz

wrap.o: wrap.c
	$(OCAMLC) -cc "$(CXX)" $(OCAML_CXXFLAGS) \
	-ccopt -ItrikRuntime/trikControl/include/ -ccopt -I$(OCAML_HEADERS_DIR) -c $< -o $@
	file  $@
	$(NM) $@

funs.cmo: funs.ml
	$(OCAMLC) -c $< -o $@

hello.cmo: hello.ml
	$(OCAMLC) -c -vmthread $< -o $@

hello.byte: wrap.o funs.cmo hello.cmo
	$(OCAMLC) $(OCAMLC_TARGET_OPTS) $^ -o $@

hello.tar.xz: hello.byte
	tar --xz -cf threads.tar.xz hello.byte
	cp hello.byte ~/h

clean:
	rm -fr *.o *.cm[ioax] hello.byte

hello.cmo: funs.cmo

.PHONY: all clean