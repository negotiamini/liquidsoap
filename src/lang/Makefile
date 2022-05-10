# Experiment with independent compilation of the language

INCDIRS = tools lang

ML  = tools/pos.ml tools/runtime_error.ml lang/type.ml
ML := $(addprefix ../,$(ML))
MLI = $(shell ls -fd $(ML:.ml=.mli) 2> /dev/null)
CMI = $(MLI:.mli=.cmi)
CMX = $(ML:.ml=.cmx)

OCAMLCOMP = OCAMLC
OCAMLC = ocamlfind ocamlopt
OCAML_CFLAGS := $(addprefix -I ../,$(INCDIRS))
OCAML_LFLAGS := -g -linkpkg
V = @

lang: $(CMI) $(CMX)
	$(V)echo Generate $@...
	$(V)$(OCAMLC) -o $@ $(OCAML_CFLAGS) $(OCAML_LFLAGS) $(CMX)

clean:
	rm -f $(ML:.ml=.cmi) $(CMX)

%.cmi: %.mli
	$(V)echo $(OCAMLCOMP) -c $<
	$(V)$(OCAMLC) $(OCAML_CFLAGS) -c $<

%.cmx: %.ml
	$(V)echo OCAMLC -c $<
	$(V)$(OCAMLC) $(OCAML_CFLAGS) -c $<
