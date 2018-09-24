I_D = draft-lhotka-netconf-restconf-transactions
REVNO = 00
DATE ?= $(shell date +%F)
MODULES = ietf-restconf-transactions
SUBMODULES =
FIGURES =
PYANG_OPTS =

# Paths for pyang
export PYANG_RNG_LIBDIR ?= /usr/share/yang/schema
export PYANG_XSLT_DIR ?= /usr/share/yang/xslt
export YANG_MODPATH ?= .:/usr/share/yang/modules/ietf:/usr/share/yang/modules/iana

yams = $(addsuffix .yang, $(MODULES))
artworks = $(addsuffix .aw, $(yams)) \
	   $(addsuffix .aw, $(FIGURES))
idrev = $(I_D)-$(REVNO)
xsldir = .tools/xslt
xslpars = --stringparam date $(DATE) --stringparam i-d-name $(I_D) \
	  --stringparam i-d-rev $(REVNO)

.PHONY: all clean gittag rnc refs validate yang

all: $(idrev).txt model.tree

refs: stdrefs.ent

yang: $(yams)

$(idrev).xml: $(I_D).xml $(artworks) figures.ent yang.ent
	@xsltproc --novalid $(xslpars) $(xsldir)/upd-i-d.xsl $< | \
	  xmllint --noent -o $@ -

$(idrev).txt: $(idrev).xml
	@xml2rfc --dtd=.tools/schema/rfc2629.dtd $<

hello.xml: $(yams) hello-external.ent
	@echo '<hello xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">' > $@
	@echo '<capabilities>' >> $@
	@echo '<capability>urn:ietf:params:netconf:base:1.1</capability>' >> $@
	@for m in $(yams); do \
	  capa=$$(pyang $(PYANG_OPTS) -f capability --capability-entity $$m); \
	  if [ "$$capa" != "" ]; then \
	    echo "<capability>$$capa</capability>" >> $@; \
	  fi \
	done
	@cat hello-external.ent >> $@
	@echo '</capabilities>' >> $@
	@echo '</hello>' >> $@

stdrefs.ent: $(I_D).xml
	xsltproc --novalid --output $@ $(xsldir)/get-refs.xsl $<

yang.ent: $(yams)
	@echo '<!-- External entities for files with modules -->' > $@
	@for f in $^; do                                                 \
	  echo '<!ENTITY '"$$f SYSTEM \"$$f.aw\">" >> $@;          \
	done

figures.ent: $(FIGURES)
ifeq ($(FIGURES),)
	@touch $@
else
	@echo '<!-- External entities for files with figures -->' > $@; \
	for f in $^; do                                            \
	  echo '<!ENTITY '"$$f SYSTEM \"$$f.aw\">" >> $@;  \
	done
endif

%.yang: %.yinx
	@xsltproc --xinclude $(xsldir)/canonicalize.xsl $< | \
	  xsltproc --output $@ $(xslpars) $(xsldir)/yin2yang.xsl -

ietf-%.yang.aw: ietf-%.yang
	@pyang $(PYANG_OPTS) --ietf $<
	@echo '<artwork>' > $@
	@echo '<![CDATA[<CODE BEGINS> file '"\"ietf-$*@$(DATE).yang\"" >> $@
	@echo >> $@
	@cat $< >> $@
	@echo >> $@
	@echo '<CODE ENDS>]]></artwork>' >> $@

%.aw: %
	@echo '<artwork><![CDATA[' > $@; \
	cat $< >> $@;                    \
	echo ']]></artwork>' >> $@

%.rnc: %.rng
	trang -I rng -O rnc $< $@

model.tree: hello.xml
	pyang $(PYANG_OPTS) -f tree -o $@ -L $<

gittag: $(idrev).txt
	git tag -a -s -m "I-D revision $(REVNO)" "rev-$(REVNO)"
	git push --follow-tags

clean:
	@rm -rf *.rng *.rnc *.sch *.dsrl hello.xml model.tree \
	        $(yams) $(idrev).* $(artworks) figures.ent yang.ent
