I_D =  # Name of the Intenet-Draft (without revision).
REVNO = # Current revision number
DATE ?= $(shell date +%F)

idrev = $(I_D)-$(REVNO)
xsldir = .tools/xslt
xslpars = --stringparam date $(DATE) --stringparam i-d-rev $(REVNO)

.PHONY: init validate clean

all:
	@$(MAKE) -C yang draft
	@$(MAKE) -C figures draft
	$(idrev).txt

$(idrev).xml: $(I_D).xml
	xsltproc -o references.ent $(xsldir)/get-refs.xsl $<
	xsltproc $(xslpars) $(xsldir)/upd-i-d.xsl $< | xmllint --noent -o $@ -

$(idrev).txt: $(idrev).xml
	xml2rfc $<

clean:
	@$(MAKE) -C figures clean
	@$(MAKE) -C yang clean
	rm -rf $(idrev).*
