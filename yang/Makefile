MODULES = 
REVDATE ?= YYYY-MM-DD
EXAMPLE_BASE = example
EXAMPLE_TYPE = get-reply
baty = $(EXAMPLE_BASE)-$(EXAMPLE_TYPE)
EXAMPLE_INST = $(baty).xml
PYANG_OPTS =

yams = $(addsuffix .yang, $(MODULES))
artworks = $(addsuffix .aw, $(yams)) $(EXAMPLE_INST).aw
schemas = $(baty).rng $(baty).sch $(baty).dsrl
y2dopts = -t $(EXAMPLE_TYPE) -b $(EXAMPLE_BASE)

.PHONY: all draft clean

all: $(schemas) model.tree

draft: $(artworks) yang.ent

hello.xml: $(yams)
	@echo '<hello xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">' > $@
	@echo '<capabilities>' >> $@
	@for m in $(yams); do \
	  capa=$$(pyang -f capability $$m | sed 's/&/&amp;/g'); \
	  if [ "$$capa" != "" ]; then \
	    echo "<capability>$$capa</capability>" >> $@; \
	  fi \
	done
	cat hello-external.ent >> $@
	@echo '</capabilities>' >> $@
	@echo '</hello>' >> $@


yang.ent: $(yams)
	@echo '<!-- External entities for files with modules -->' > $@
	@for f in $^; do                                                 \
	  echo '<!ENTITY '"$$f SYSTEM \"yang/$$f.aw\">" >> $@;          \
	done
ifneq ($EXAMPLE_INST,)
	@echo '<!ENTITY '"$(EXAMPLE_INST) SYSTEM \"yang/$(EXAMPLE_INST).aw\">" >> $@
endif

%.yang.aw: %.yang
	@pyang --ietf $<
	@echo '<artwork>' > $@
	@echo '<![CDATA[<CODE BEGINS> file '"\"$*@$(REVDATE).yang\"" >> $@
	@echo >> $@
	@cat $< >> $@
	@echo >> $@
	@echo '<CODE ENDS>]]></artwork>' >> $@

%.aw: %
	@echo '<artwork><![CDATA[' > $@; \
	cat $< >> $@;                    \
	echo ']]></artwork>' >> $@

$(schemas): hello.xml $(yams)
	yang2dsdl $(y2dopts) -L $<

validate: $(EXAMPLE_INST) $(schemas)
	yang2dsdl -j -s $(y2dopts) -v $<

model.tree: hello.xml $(yams)
	pyang -f tree -o $@ -L $<

clean:
	@rm -rf $(artworks) $(schemas) yang.ent hello.xml model.tree
