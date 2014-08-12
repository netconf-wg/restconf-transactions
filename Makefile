I_D =  # Name of the Internet-Draft (without revision).
REVNO = # Current revision number
DATE ?= $(shell date +%F)

idrev = $(I_D)-$(REVNO)
xsldir = .tools/xslt
xslpars = --stringparam date $(DATE) -- stringparam i-d-name $(I_D) \
	  --stringparam i-d-rev $(REVNO)

.PHONY: init validate clean

all: $(idrev).txt

$(idrev).xml: $(I_D).xml
	@$(MAKE) -C yang draft
	@$(MAKE) -C figures draft
	xsltproc -o references.ent $(xsldir)/get-refs.xsl $<
	xsltproc $(xslpars) $(xsldir)/upd-i-d.xsl $< | xmllint --noent -o $@ -

$(idrev).txt: $(idrev).xml
	xml2rfc $<

clean:
	@$(MAKE) -C figures clean
	@$(MAKE) -C yang clean
	rm -rf $(idrev).* references.ent
