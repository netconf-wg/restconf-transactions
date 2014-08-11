MODULES = ietf-routing ietf-ipv4-unicast-routing ietf-ipv6-unicast-routing
REVDATE ?= YYYY-MM-DD
SAMPLE_BASE = sample
SAMPLE_TYPE = get-reply
baty = $(SAMPLE_BASE)-$(SAMPLE_TYPE)
SAMPLE_INST = $(baty).xml
PYANG_OPTS =

yams = $(addsuffix .yang, $(MODULES))
artworks = $(addsuffix .aw, $(yams)) $(SAMPLE_INST).aw
schemas = $(baty).rng $(baty).sch $(baty).dsrl
y2dopts = -t $(SAMPLE_TYPE) -b $(SAMPLE_BASE)

.PHONY: all draft clean

all: $(schemas) model.tree

draft: $(artworks) yang.ent

hello.xml: $(yams)
	@echo '<hello xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">' > $@
	@echo '  <capabilities>' >> $@
	@for m in $(yams); do \
	  capa=$$(pyang -f capability $$m | sed 's/&/&amp;/g'); \
	  if [ "$$capa" != "" ]; then \
	    echo "    <capability>$$capa</capability>" >> $@; \
	  fi \
	done 
	@echo '  </capabilities>' >> $@
	@echo '</hello>' >> $@


yang.ent: $(yams)
	@echo '<!-- External entities for files with modules -->' > $@
	@for f in $^; do                                                 \
	  echo '<!ENTITY '"$$f SYSTEM \"yang/$$f.aw\">" >> $@;          \
	done
ifneq ($SAMPLE_INST,)
	@echo '<!ENTITY '"$(SAMPLE_INST) SYSTEM \"yang/$(SAMPLE_INST).aw\">" >> $@
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

validate: $(SAMPLE_INST) $(schemas)
	yang2dsdl -j -s $(y2dopts) -v $<

model.tree: hello.xml $(yams)
	pyang -f tree -o $@ -L $<

clean:
	@rm -rf $(artworks) $(schemas) yang.ent hello.xml model.tree
