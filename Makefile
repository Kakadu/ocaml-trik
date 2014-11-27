#MY_LLP=LD_LIBRARY_PATH=/opt/trik-sdk/sysroots/armv5te-oe-linux-gnueabi/lib
$(warning BEGINNING)

SOURCE_OE=`opam config var prefix`/trik-sdk-linux/environment-setup-armv5te-oe-linux-gnueabi
IGNORE := $(shell bash -c "source $(SOURCE_OE); env | sed 's/=/:=/' | sed 's/^/export /' > makeenv")
include makeenv

all:
	$(MAKE) hello.tar.xz

$(warning ${PKG_CONFIG_PATH})
$(warning ${PATH})

OCAMLC=ocamlfind -toolchain android c
OCAMLOPT=ocamlfind -toolchain android opt

#OCAMLWHERE=$(shell $(MY_LLP) $(OCAMLDIST)/bin/ocamlc -where)
#OCAMLC_TARGET=$(MY_LLP) $(OCAMLDIST)/bin/ocamlc
#OCAMLOPT_TARGET=$(MY_LLP) $(OCAMLDIST)/bin/ocamlopt
#OCAMLC=ocamlc
#OCAML_HEADERS_DIR=$(OCAMLWHERE)/caml
#VMTHREADS_DIR=$(OCAMLWHERE)/vmthreads
#SYSTHREADS_DIR=$(OCAMLWHERE)/threads

CXXFLAGS=-std=c++11 -ItrikRuntime/trikControl/include -I$(shell $(OCAMLC) -where)/caml
$(warning CXXFLAGS=$(CXXFLAGS) )
#OCAMLC_TARGET_OPTS=-custom -cc "$(CC)" \
	-ccopt -L$(VMTHREADS_DIR)  $(VMTHREADS_DIR)/threads.cma \
	-cclib -lstdc++
#OCAMLOPT_TARGET_OPTS= -cc "$(CC)" \
	-ccopt -L$(SYSTHREADS_DIR) unix.cmxa  $(SYSTHREADS_DIR)/threads.cmxa \
	-cclib -lstdc++
QTMODULES=QtGuiE
OCAMLC_TARGET_OPTS += $(addprefix -cclib ,$(shell pkg-config --libs $(QTMODULES) ) )
$(warning $(OCAMLC_TARGET_OPTS) )

OCAMLC_TARGET_OPTS += -ccopt -Llibs -cclib -ltrikControl
OCAMLOPT_TARGET_OPTS += $(addprefix -cclib ,$(shell pkg-config --libs $(QTMODULES) ) )
OCAMLOPT_TARGET_OPTS += -ccopt -Llibs -cclib -ltrikControl

OCAML_CXXFLAGS =  $(addprefix -ccopt , $(CXXFLAGS) )
OCAML_CXXFLAGS += $(addprefix -ccopt , $(shell pkg-config --cflags QtGuiE) )
OCAML_CXXFLAGS += -ccopt -I$(OCAML_HEADERS_DIR) -ccopt -I$(OCAMLWHERE)/threads/ -ccopt -save-temps


wrap.o: wrap.c
	$(OCAMLC) -cc "$(CXX)" $(OCAML_CXXFLAGS) \
	-ccopt -ItrikRuntime/trikControl/include/ -ccopt -I$(OCAML_HEADERS_DIR) -c $< -o $@
	#file  $@
	#$(NM) $@

funs.cmo: funs.ml
	$(OCAMLC) -c $< -o $@

funs.cmx: funs.ml
	$(OCAMLOPT) -c $< -o $@

hello.cmo: hello.ml
	$(OCAMLC) -c -vmthread $< -o $@

hello.cmx: hello.ml
	$(OCAMLOPT) -c -thread $< -o $@

hello.byte: wrap.o funs.cmo hello.cmo
	$(OCAMLC) $(OCAMLC_TARGET_OPTS) $^ -o $@

hello.native: wrap.o funs.cmx hello.cmx
	$(OCAMLOPT) $(OCAMLOPT_TARGET_OPTS) $^ -o $@

hello.tar.xz: hello.native
	tar --xz -cf threads.tar.xz hello.native
	#cp hello.byte ~/h

clean:
	rm -fr *.o *.cm[ioax] hello.byte hello.native

hello.cmo: funs.cmo

.PHONY: all clean
