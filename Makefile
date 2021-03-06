#MY_LLP=LD_LIBRARY_PATH=/opt/trik-sdk/sysroots/armv5te-oe-linux-gnueabi/lib

SOURCE_OE=`opam config var prefix`/trik-sdk-linux/environment-setup-armv5te-oe-linux-gnueabi
IGNORE := $(shell bash -c "source $(SOURCE_OE); env | sed 's/=/:=/' | sed 's/^/export /' > trikenv")
include trikenv

all:
	$(MAKE) hello.tar.xz

.PHONY: trikRuntime
trikRuntime:
	cd trikRuntime && qmake -r && $(MAKE)

#$(warning ${PKG_CONFIG_PATH})
#$(warning ${PATH})

#OCAMLC=ocamlfind   -toolchain trik c   -package threads
OCAMLOPT=ocamlfind -toolchain trik opt -package threads,react -thread #-verbose

#OCAMLWHERE=$(shell $(MY_LLP) $(OCAMLDIST)/bin/ocamlc -where)
#OCAMLC_TARGET=$(MY_LLP) $(OCAMLDIST)/bin/ocamlc
#OCAMLOPT_TARGET=$(MY_LLP) $(OCAMLDIST)/bin/ocamlopt
#OCAMLC=ocamlc
#OCAML_HEADERS_DIR=$(OCAMLWHERE)/caml
#VMTHREADS_DIR=$(OCAMLWHERE)/vmthreads
#SYSTHREADS_DIR=$(OCAMLWHERE)/threads

CXXFLAGS=-std=c++11 -ItrikRuntime/trikControl/include -I$(shell $(OCAMLOPT) -where)

#$(warning CXXFLAGS=$(CXXFLAGS) )
#OCAMLC_TARGET_OPTS=-custom -cc "$(CC)" \
	-ccopt -L$(VMTHREADS_DIR)  $(VMTHREADS_DIR)/threads.cma \
	-cclib -lstdc++
#OCAMLOPT_TARGET_OPTS= -cc "$(CC)" \
	-ccopt -L$(SYSTHREADS_DIR) unix.cmxa  $(SYSTHREADS_DIR)/threads.cmxa \
	-cclib -lstdc++
QTMODULES=QtGuiE QtNetworkE
OCAMLC_TARGET_OPTS += $(addprefix -cclib ,$(shell pkg-config --libs $(QTMODULES) ) )
#$(warning $(OCAMLC_TARGET_OPTS) )

OCAMLC_TARGET_OPTS += -ccopt -Llibs -cclib -ltrikControl
OCAMLOPT_TARGET_OPTS += $(addprefix -cclib ,$(shell pkg-config --libs $(QTMODULES) ) )
OCAMLOPT_TARGET_OPTS += -ccopt -LtrikRuntime/bin/arm-release -cclib -lqslog -cclib -ltrikKernel -cclib -ltrikControl -cclib -lpthread -cclib -lstdc++

OCAML_CXXFLAGS =  $(addprefix -ccopt , $(CXXFLAGS) )
OCAML_CXXFLAGS += $(addprefix -ccopt , $(shell pkg-config --cflags QtGuiE) )
OCAML_CXXFLAGS += #-ccopt -I$(OCAML_HEADERS_DIR) -ccopt -I$(OCAMLWHERE)/threads/ -ccopt -save-temps

brick.o: mlheaders.h
brick.o: brick.c
	$(OCAMLOPT) -cc "$(CXX)" $(OCAML_CXXFLAGS) -ccopt -ItrikRuntime/trikControl/include/ -c $< -o $@

wrap.o: mlheaders.h
wrap.o: wrap.c
	$(OCAMLOPT) -cc "$(CXX)" $(OCAML_CXXFLAGS) -ccopt -ItrikRuntime/trikControl/include/ -c $< -o $@

mailbox.o: mlheaders.h
mailbox.o: mailbox.c
	$(OCAMLOPT) -cc "$(CXX)" $(OCAML_CXXFLAGS) -ccopt -ItrikRuntime/trikControl/include/ -c $< -o $@

#funs.cmo: funs.ml
#	$(OCAMLC) -c $< -o $@

funs.cmx: funs.ml
	$(OCAMLOPT) -c $< -o $@

#hello.cmo: hello.ml
#	$(OCAMLC) -c -vmthread $< -o $@

react1.cmx: react1.ml funs.cmx
	$(OCAMLOPT) -c -thread $< -o $@

hello.cmx: hello.ml
	$(OCAMLOPT) -c -thread $< -o $@

#hello.byte: wrap.o funs.cmo hello.cmo
#	$(OCAMLC) $(OCAMLC_TARGET_OPTS) $^ -o $@

hello.native: brick.o wrap.o mailbox.o funs.cmx hello.cmx
	$(OCAMLOPT) -linkpkg $(OCAMLOPT_TARGET_OPTS) $^ -o $@

react1.native: brick.o wrap.o mailbox.o funs.cmx react1.cmx
	$(OCAMLOPT) -linkpkg $(OCAMLOPT_TARGET_OPTS) $^ -o $@

hello.tar.xz: hello.native react1.native
	tar --xz -cvf $^
	#cp hello.byte ~/h

clean:
	$(RM) -rf *.o *.cm[ioax] hello.byte hello.native react1.native

# depends
hello.cmo: funs.cmo
hello.cmx: funs.cmx


.PHONY: all clean
